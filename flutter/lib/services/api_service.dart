import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_watchers_app/models/goal.dart';
import 'package:wallet_watchers_app/models/collaborative_goal.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.8:3000/api';
  bool _useMock = false; // Toggle this to switch between mock and real API
  String? _userId;

  ApiService() {
    _loadUserId(); // Auto-load userId on creation
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    print('Loaded userId: $_userId');
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    _userId = userId;
    print('Saved userId: $_userId');
  }

  void setUserId(String userId) {
    if (userId.isEmpty || userId == 'mock_user_id') {
      throw Exception('Invalid user ID provided: $userId');
    }
    _saveUserId(userId);
  }

  String get userId => _userId ?? '';

  void toggleMock(bool useMock) {
    _useMock = useMock;
    print('Mock mode: $_useMock');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      final mockResponse = {
        'message': 'Login successful',
        'user': {
          'id': 'mock_user_id',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': email,
          'phoneNo': '1234567890',
        },
      };
      final user = mockResponse['user'] as Map<String, dynamic>?;
      if (user == null || user['id'] == null) {
        throw Exception('User ID missing in mock response');
      }
      await _saveUserId(user['id'] as String);
      return mockResponse;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/postLogin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final userId = responseData['user']?['id'];
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID missing in response');
        }
        await _saveUserId(userId);
        return responseData;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNo,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      final mockResponse = {
        'message': 'User created successfully',
        'user': {
          'id': 'mock_user_id',
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNo': phoneNo,
        },
      };
      final user = mockResponse['user'] as Map<String, dynamic>?;
      if (user == null || user['id'] == null) {
        throw Exception('User ID missing in mock response');
      }
      await _saveUserId(user['id'] as String);
      return mockResponse;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
              'password': password,
              'phoneNo': phoneNo,
            }),
          )
          .timeout(const Duration(seconds: 10));
      print("response ${response.body}");
      final responseData = jsonDecode(response.body);
      print("responseData ${responseData}");
      if (response.statusCode == 201) {
        print("responseData ${responseData}");
        final userId = responseData['user']?['_id'];
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID missing in response');
        }
        await _saveUserId(userId);
        return responseData;
      } else {
        throw Exception('Signup failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  Future<Map<String, dynamic>> saveReceipt(String text) async {
    if (_userId == null || _userId!.isEmpty) {
      await _loadUserId();
      if (_userId == null || _userId!.isEmpty) {
        throw Exception('User ID not set. Please log in first.');
      }
    }
    if (text.trim().isEmpty) {
      throw Exception('Receipt text cannot be empty.');
    }

    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'message': 'Receipt saved successfully',
        'text': text,
      };
    }

    try {
      final payload = {
        'userId': _userId,
        'text': text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      print('Saving receipt with payload: $payload');
      final response = await http
          .post(
            Uri.parse('$baseUrl/receipts'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_userId',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to save receipt: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saving receipt: $e');
      rethrow;
    }
  }

  Future<List<Goal>> fetchGoals() async {
    if (_userId == null || _userId!.isEmpty) await _loadUserId();

    final response = await http.get(Uri.parse('$baseUrl/goals/$_userId'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Goal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load goals');
    }
  }

  Future<Goal> createGoal(Goal goal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...goal.toJson(),
        'userId': _userId,
      }),
    );

    if (response.statusCode == 201) {
      return Goal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create goal');
    }
  }

  Future<Goal> updateGoal(Goal goal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/goals/${goal.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(goal.toJson()),
    );

    if (response.statusCode == 200) {
      return Goal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update goal');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final response = await http.delete(Uri.parse('$baseUrl/goals/$goalId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete goal');
    }
  }

  Future<Goal> toggleGoalAchieved(Goal goal) async {
    return await updateGoal(goal.copyWith(isAchieved: !goal.isAchieved));
  }

  Future<Map<String, dynamic>> addIncome(
      {required double incomeAmount, required String incomeName}) async {
    if (_userId!.isEmpty) await _loadUserId();
    if (_userId!.isEmpty) {
      throw Exception('User ID not set. Please login first.');
    }

    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      final mockResponse = {
        'userId': _userId,
        'incomeAmount': incomeAmount,
        'incomeName': incomeName,
      };
      print('Mock API: Income added successfully');
      print('Response: \\${jsonEncode(mockResponse)}');
      return mockResponse;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/income/postIncome'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_userId',
            },
            body: jsonEncode({
              'userId': _userId,
              'incomeAmount': incomeAmount,
              'incomeName': incomeName,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Income failed: \\${response.statusCode}');
      }
    } catch (e) {
      print('Exception while adding income: $e');
      rethrow;
    }
  }

  Future<List<Transaction>> fetchExpenses(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses/postAllExpenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((json) => Transaction.fromJson(json, TransactionType.expense))
          .toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<List<Transaction>> fetchIncomes(String userId) async {
    print('userIdddd: $userId');
    final response =
        await http.get(Uri.parse('$baseUrl/income/getIncome?userId=$userId'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((json) => Transaction.fromJson(json, TransactionType.income))
          .toList();
    } else {
      throw Exception('Failed to load incomes');
    }
  }

  Future<String> getWebChatExternalId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'guest';
    final externalId = 'wallet_user_$userId'; // Must be unique for each user
    await prefs.setString('webChatExternalId', externalId);
    return externalId;
  }

  Future<void> deleteCollaborativeGoal(String goalId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/collaborative-goals/$goalId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete collaborative goal');
    }
  }

  Future<void> addFriendToGoal(String goalId, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/collaborative-goals/add-friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'goalId': goalId, 'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to invite friend');
    }
  }

  Future<void> updateContribution(String goalId, double amount) async {
    final uid = await userId;
    final response = await http.put(
      Uri.parse('$baseUrl/collaborative-goals/update-contribution'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'goalId': goalId, 'userId': uid, 'amount': amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update contribution');
    }
  }

  Future<void> removeFriend(String goalId, String userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/collaborative-goals/remove-friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'goalId': goalId, 'userId': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove friend');
    }
  }

  Future<void> leaveGoal(String goalId) async {
    final uid = await userId;
    final response = await http.put(
      Uri.parse('$baseUrl/collaborative-goals/leave'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'goalId': goalId, 'userId': uid}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to leave goal');
    }
  }

  Future<void> respondToInvite(String goalId, String status) async {
    final uid = await userId;
    final response = await http.put(
      Uri.parse('$baseUrl/collaborative-goals/respond-invite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'goalId': goalId, 'userId': uid, 'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to respond to invite');
    }
  }

  Future<List<CollaborativeGoal>> fetchCollaborativeGoals() async {
    final uid = await userId;
    final response =
        await http.get(Uri.parse('$baseUrl/collaborative-goals/$uid'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CollaborativeGoal.fromJson(json)).toList();
    } else {
      print('fetchCollaborativeGoals failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load collaborative goals');
    }
  }

  Future<List<CollaborativeGoal>> fetchInvites() async {
    final uid = await userId;
    final response = await http
        .get(Uri.parse('$baseUrl/collaborative-goals/notifications/$uid'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CollaborativeGoal.fromJson(json)).toList();
    } else {
      print('fetchInvites failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load invites');
    }
  }

  Future<void> createCollaborativeGoal(String title, double amount) async {
    final uid = await userId;
    final response = await http.post(
      Uri.parse('$baseUrl/collaborative-goals/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'totalTargetPerUser': amount,
        'createdBy': uid,
        'participants': [
          {'userId': uid, 'savedAmount': 0, 'status': 'accepted'}
        ]
      }),
    );
    print('Goal creation response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 201) {
      throw Exception('Failed to create collaborative goal');
    }
  }

  Future<Map<String, dynamic>> addExpense(Transaction transaction) async {
    if (_userId == null || _userId!.isEmpty) {
      await _loadUserId();
    }

    if (_userId == null || _userId!.isEmpty) {
      throw Exception('User ID not set. Please login first.');
    }

    final categoryName = transaction.category.toString().split('.').last;
    final expenseName = transaction.description?.trim().isNotEmpty == true
        ? transaction.description!
        : "Unnamed";

    try {
      // Step 1: Save expense
      final saveResponse = await http
          .post(
            Uri.parse('$baseUrl/expenses/postExpenses'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_userId',
            },
            body: jsonEncode({
              'userId': _userId,
              'expenseName': expenseName,
              'expenseAmount': transaction.amount,
              'categoryName': categoryName,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (saveResponse.statusCode != 201) {
        print("❌ Failed to save expense: ${saveResponse.statusCode}");
        throw Exception('Expense failed: ${saveResponse.statusCode}');
      }

      final savedExpense = jsonDecode(saveResponse.body);
      print("✅ Expense saved: $savedExpense");

      // Step 2: Deduct from AI budget
      final deductResponse = await http
          .post(
            Uri.parse('$baseUrl/ai/deductExpense'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_userId',
            },
            body: jsonEncode({
              'userId': _userId,
              'categoryName': categoryName,
              'expenseAmount': transaction.amount,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (deductResponse.statusCode == 200) {
        final updatedBudget = jsonDecode(deductResponse.body);
        print("✅ Budget updated: $updatedBudget");
      } else {
        print(
            "⚠️ Failed to deduct from AI budget: ${deductResponse.statusCode}");
      }

      return savedExpense;
    } catch (e) {
      print('❌ Exception while adding transaction: $e');
      print('📦 Transaction details: ${jsonEncode(transaction.toJson())}');
      rethrow;
    }
  }
}
