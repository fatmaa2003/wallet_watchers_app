import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
<<<<<<< HEAD
  bool _useMock = false;
  String _userId = '';
=======
  bool _useMock = false; // Toggle this to switch between mock and real API
  String? _userId;
>>>>>>> f35ba88924d57479f527485d5509de6526c05fe0

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

  String get userId => _userId;

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
      final response = await http.post(
        Uri.parse('$baseUrl/users/postLogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      print("response ${response.body}");
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
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phoneNo': phoneNo,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        final userId = responseData['user']?['id'];
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

  Future<Map<String, dynamic>> addTransaction(Transaction transaction) async {
    if (_userId.isEmpty) await _loadUserId();
    if (_userId.isEmpty) {
      throw Exception('User ID not set. Please login first.');
    }

    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      final mockResponse = {
        'id': transaction.id,
        'userId': _userId,
        'amount': transaction.amount,
        'description': transaction.description,
        'date': transaction.date.toIso8601String(),
        'type': transaction.type.toString().split('.').last,
        'category': transaction.category.toString().split('.').last,
        'createdAt': DateTime.now().toIso8601String(),
      };

      print('Mock API: Transaction added successfully');
      print('Response: ${jsonEncode(mockResponse)}');

      return mockResponse;
    }

    try {
      print(transaction);
      final response = await http.post(
        Uri.parse('$baseUrl/expenses/postExpenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $_userId', // TODO: Replace with proper JWT token
        },
        body: jsonEncode({
          'userId': _userId,
          'expenseAmount': transaction.amount,
          // 'description': transaction.description,
          // 'date': transaction.date.toIso8601String(),
          // 'type': transaction.type.toString().split('.').last,
          'categoryName': transaction.category.toString().split('.').last,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Transaction failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while adding transaction: $e');
      print('Transaction details: ${jsonEncode(transaction.toJson())}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveReceipt(String text) async {
    if (_userId.isEmpty) await _loadUserId();
    if (_userId.isEmpty) {
      throw Exception('User ID not set. Please login first.');
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
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      };
      print('Sending payload to /api/receipts: $payload'); // Debug print
      final response = await http.post(
        Uri.parse('$baseUrl/receipts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_userId', // Added Authorization header
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to save receipt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving receipt: $e');
    }
  }
}
