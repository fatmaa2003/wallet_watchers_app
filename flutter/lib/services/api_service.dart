import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_watchers_app/models/transaction.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  bool _useMock = true; // Toggle this to switch between mock and real API
  String? _userId;

  // Set the current user ID
  void setUserId(String userId) {
    _userId = userId;
  }

  // Get the current user ID
  String? get userId => _userId;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (_useMock) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful response
      final mockResponse = {
        'message': 'Login successful',
        'user': {
          'id': 'mock_user_id',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': email,
          'phoneNo': '1234567890',
        }
      };

      print('Mock API: Login successful');
      print('Response: ${jsonEncode(mockResponse)}');
      return mockResponse;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print('Login successful: ${response.body}');
        final responseData = jsonDecode(response.body);
        // Set the user ID after successful login
        setUserId(responseData['user']['id']);
        return responseData;
      } else {
        print('Error during login: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to login');
      }
    } catch (e) {
      print('Exception while logging in: $e');
      rethrow;
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful response
      final mockResponse = {
        'message': 'User created successfully',
        'user': {
          'id': 'mock_user_id',
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNo': phoneNo,
        }
      };

      print('Mock API: User created successfully');
      print('Response: ${jsonEncode(mockResponse)}');
      return mockResponse;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phoneNo': phoneNo,
        }),
      );

      if (response.statusCode == 201) {
        print('User created successfully: ${response.body}');
        final responseData = jsonDecode(response.body);
        // Set the user ID after successful signup
        setUserId(responseData['user']['id']);
        return responseData;
      } else {
        print('Error creating user: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('Exception while creating user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addTransaction(Transaction transaction) async {
    if (_userId == null) {
      throw Exception('User ID not set. Please authenticate first.');
    }

    if (_useMock) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful response
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
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $_userId', // Add user ID in Authorization header
        },
        body: jsonEncode({
          'userId': _userId,
          'amount': transaction.amount,
          'description': transaction.description,
          'date': transaction.date.toIso8601String(),
          'type': transaction.type.toString().split('.').last,
          'category': transaction.category.toString().split('.').last,
        }),
      );

      if (response.statusCode == 201) {
        print('Transaction added successfully: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print('Error adding transaction: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to add transaction');
      }
    } catch (e) {
      print('Exception while adding transaction: $e');
      rethrow;
    }
  }

  // Method to toggle between mock and real API
  void toggleMock(bool useMock) {
    _useMock = useMock;
  }
}
