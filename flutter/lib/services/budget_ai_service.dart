import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static const String nodeApiUrl =
      'http://localhost:3000/api'; // Update to your actual IP/port

  // 🔐 Get stored userId from SharedPreferences
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (userId.isEmpty)
      throw Exception('User ID not found in SharedPreferences');
    return userId;
  }

  /// 🔁 Generate AI budget prediction for next month
  /// Returns both message and budget (if exists or new)
  Future<Map<String, dynamic>> generateBudget() async {
    final userId = await _getUserId();
    final url = Uri.parse('$nodeApiUrl/ai/generateBudget');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Failed to generate budget: ${response.body}');
    }
  }

  /// 📥 Get all saved budgets for this user
  Future<List<Map<String, dynamic>>> fetchSavedBudgets() async {
    final userId = await _getUserId();
    final url = Uri.parse('$nodeApiUrl/ai/budgets/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('❌ Failed to fetch saved budgets: ${response.body}');
    }
  }

  /// ➖ Deduct an expense from the budget limit for a specific category
  Future<void> deductExpense(String categoryName, double amount) async {
    final userId = await _getUserId();
    final url = Uri.parse('$nodeApiUrl/ai/deductExpense');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'categoryName': categoryName,
        'expenseAmount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to deduct expense from budget');
    }
  }
}
