import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static const String nodeApiUrl = 'http://172.29.67.231:3000/api';

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (userId.isEmpty)
      throw Exception('User ID not found in SharedPreferences');
    return userId;
  }

  /// 🔁 Generate AI budget prediction via Node.js proxy
  Future<Map<String, dynamic>> generateBudget() async {
    final userId = await _getUserId();
    final url = Uri.parse('$nodeApiUrl/ai/generateBudget');
    print("🔁 Calling Node.js for budget prediction: $userId");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    print("✅ Node.js response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Failed to generate budget: ${response.body}');
    }
  }

  /// 📥 Get saved budget predictions
  Future<List<Map<String, dynamic>>> fetchSavedBudgets() async {
    final userId = await _getUserId();
    final url = Uri.parse('$nodeApiUrl/ai/budgets/$userId');
    print("📥 Fetching saved budgets for userId: $userId");

    final response = await http.get(url);

    print("📦 Response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('❌ Failed to fetch saved budgets: ${response.body}');
    }
  }
}
