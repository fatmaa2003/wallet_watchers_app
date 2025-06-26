import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_watchers_app/models/goal.dart';
import 'package:wallet_watchers_app/models/collaborative_goal.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet_watchers_app/models/category.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
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
        final token = responseData['token'];
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID missing in response');
        }
        await _saveUserId(userId);
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
        }
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final payload = {
        'userId': _userId,
        'text': text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      print('Saving receipt with payload: $payload');
      final response = await http
          .post(
            Uri.parse('$baseUrl/receipts'),
            headers: headers,
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

  Future<Map<String, dynamic>> addIncome({
    required double incomeAmount, 
    required String incomeName,
    DateTime? date,
  }) async {
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
        'date': date?.toIso8601String(),
      };
      print('Mock API: Income added successfully');
      print('Response: ${jsonEncode(mockResponse)}');
      return mockResponse;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http
          .post(
            Uri.parse('$baseUrl/income/postIncome'),
            headers: headers,
            body: jsonEncode({
              'userId': _userId,
              'incomeAmount': incomeAmount,
              'incomeName': incomeName,
              'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Income failed: ${response.statusCode}');
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

  Future<Transaction> addExpense({
    required String expenseName,
    required double amount,
    required Category category,
    required DateTime date,
    bool isBank = false,
    String? bankName,
    String? cardNumber,
    String? accountNumber,
  }) async {
    if (_userId == null || _userId!.isEmpty) {
      await _loadUserId();
    }

    if (_userId == null || _userId!.isEmpty) {
      throw Exception('User ID not set. Please login first.');
    }

    try {
      print('Adding expense with data:');
      print('userId: $_userId');
      print('expenseName: $expenseName');
      print('expenseAmount: $amount');
      print('categoryName: ${category.categoryName}');
      print('isBank: $isBank');
      if (isBank) {
        print('bankName: $bankName');
        print('cardNumber: $cardNumber');
        print('accountNumber: $accountNumber');
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        Uri.parse('$baseUrl/expenses/postExpenses'),
        headers: headers,
        body: jsonEncode({
          'userId': _userId,
          'expenseName': expenseName,
          'expenseAmount': amount,
          'categoryName': category.categoryName,
          'date': date.toIso8601String(),
          'isBank': isBank,
          'bankName': bankName,
          'cardNumber': cardNumber,
          'accountNumber': accountNumber,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // If the response body is empty or null, create a Transaction from the request data
        if (response.body.isEmpty) {
          return Transaction(
            id: const Uuid().v4(),
            amount: amount,
            expenseName: expenseName,
            date: date,
            type: TransactionType.expense,
            category: category,
            isBank: isBank,
            bankName: bankName,
            cardNumber: cardNumber,
            accountNumber: accountNumber,
          );
        }

        // Otherwise, try to parse the response
        try {
          return Transaction.fromJson(
              jsonDecode(response.body), TransactionType.expense);
        } catch (e) {
          print('Error parsing response: $e');
          // If parsing fails, create a Transaction from the request data
          return Transaction(
            id: const Uuid().v4(),
            amount: amount,
            expenseName: expenseName,
            date: date,
            type: TransactionType.expense,
            category: category,
            isBank: isBank,
            bankName: bankName,
            cardNumber: cardNumber,
            accountNumber: accountNumber,
          );
        }
      } else {
        throw Exception(
            'Failed to add expense: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding expense: $e');
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<List<Transaction>> getExpensesByDate(
      String userId, DateTime date) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Transaction(
          id: '1',
          amount: 50.0,
          expenseName: 'Mock Transaction 1',
          category: Category(id: '1', categoryName: 'Food'),
          type: TransactionType.expense,
          date: date,
        ),
        Transaction(
          id: '2',
          amount: 75.0,
          expenseName: 'Mock Transaction 2',
          category: Category(id: '3', categoryName: 'Shopping'),
          type: TransactionType.expense,
          date: date,
        ),
      ];
    }

    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse(
            '$baseUrl/expenses/getExpensesByDate?userId=$userId&date=$dateStr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userId',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Transaction.fromJson(json, TransactionType.expense))
            .toList();
      } else {
        throw Exception('Failed to fetch expenses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }

  Future<void> deleteExpense(String userId, String expenseName) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      print('🧪 Mock API: Expense deleted successfully');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/expenses/deleteExpense?userId=$userId&expenseName=$expenseName'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception while deleting expense: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateExpense(Transaction transaction) async {
    if (_userId == null || _userId!.isEmpty) {
      await _loadUserId();
    }

    if (_userId == null || _userId!.isEmpty) {
      throw Exception('User ID not set. Please login first.');
    }

    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      final mockResponse = {
        'userId': _userId,
        'expenseAmount': transaction.amount,
        'expenseName': transaction.expenseName.isNotEmpty
            ? transaction.expenseName
            : 'Unnamed',
        'categoryName': transaction.category.toString().split('.').last,
      };
      print('🧪 Mock API: Transaction updated successfully');
      print('🧾 Response: ${jsonEncode(mockResponse)}');
      return mockResponse;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final expenseName = transaction.expenseName.trim().isNotEmpty
          ? transaction.expenseName
          : "Unnamed";

      print('Updating expense with data:');
      print('userId: $_userId');
      print('expenseName: $expenseName');
      print('expenseAmount: ${transaction.amount}');

      final response = await http
          .patch(
            Uri.parse('$baseUrl/expenses/updateExpense'),
            headers: headers,
            body: jsonEncode({
              'userId': _userId,
              'expenseName': expenseName,
              'expenseAmount': transaction.amount,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Expense update failed: ${response.statusCode} - ${response.body}');
      }

      final updatedExpense = jsonDecode(response.body);
      print("✅ Expense updated: $updatedExpense");
      return updatedExpense;
    } catch (e) {
      print('❌ Exception while updating transaction: $e');
      print('📦 Transaction details: ${jsonEncode(transaction.toJson())}');
      rethrow;
    }
  }

  Future<List<Category>> getAllCategories() async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Category(id: '1', categoryName: 'Food'),
        Category(id: '2', categoryName: 'Transport'),
        Category(id: '3', categoryName: 'Shopping'),
        Category(id: '4', categoryName: 'Bills'),
        Category(id: '5', categoryName: 'Entertainment'),
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/getAllCategories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Return default categories if the API call fails
      return [
        Category(id: '1', categoryName: 'Food'),
        Category(id: '2', categoryName: 'Transport'),
        Category(id: '3', categoryName: 'Shopping'),
        Category(id: '4', categoryName: 'Bills'),
        Category(id: '5', categoryName: 'Entertainment'),
      ];
    }
  }

  Future<int> getPendingInvitesCount() async {
    if (_userId == null || _userId!.isEmpty) {
      await _loadUserId();
    }

    final invites = await fetchInvites();
    print("Notifications count: ${invites.length}");
    return invites.length;
  }

  Future<List<Map<String, dynamic>>> getCardsByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cards/getCardsByUserId?userId=$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Error getting cards: $e');
    }
  }

  Future<Map<String, dynamic>> postCard(String userId, Map<String, dynamic> cardData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cards/postCard'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'cardData': cardData,
        }),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add card');
      }
    } catch (e) {
      throw Exception('Error adding card: $e');
    }
  }

  Future<Map<String, dynamic>> deleteCard(String userId, String cardNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cards/deleteCard?userId=$userId&cardName=$cardNumber'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete card');
      }
    } catch (e) {
      throw Exception('Error deleting card: $e');
    }
  }

  Future<void> updateIncome(String userId, Transaction income) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.patch(
      Uri.parse('$baseUrl/income/updateIncome'),
      headers: headers,
      body: jsonEncode({
        'userId': userId,
        'incomeName': income.expenseName,
        'incomeAmount': income.amount,
        'date': income.date.toIso8601String(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update income: [${response.statusCode}] - ${response.body}');
    }
  }

  Future<void> deleteIncome(String userId, String incomeName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.delete(
      Uri.parse('$baseUrl/income/deleteIncome?userId=$userId&incomeName=$incomeName'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete income: [${response.statusCode}] - ${response.body}');
    }
  }
}
