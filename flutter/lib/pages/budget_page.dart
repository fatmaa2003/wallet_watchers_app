import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/budget_ai_service.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/models/user.dart';

class BudgetPage extends StatefulWidget {
  final User user;

  const BudgetPage({Key? key, required this.user}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  Map<String, dynamic>? _budgetData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getPredictedBudget();
  }

  Future<void> _getPredictedBudget() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final budgetService = BudgetService();
      final result = await budgetService.generateBudget();
      print("🎯 Budget result: $result");

      setState(() {
        _budgetData = result;
      });
    } catch (e) {
      print("❌ Error fetching budget: $e");
      setState(() {
        _error = 'Failed to generate budget: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBudgetList() {
    if (_budgetData == null) return const SizedBox.shrink();

    final categoryList = _budgetData!['byCategory'] as List;
    final total = _budgetData!['total'];
    final predictedMonth = _budgetData!['predictedMonth'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AI Predicted Budget for $predictedMonth",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          "Total Spending Limit: \$${total.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          "Suggested Category Limits:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...categoryList.map((item) {
          final cat = item['category'];
          final amt = item['amount'];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.category),
              title: Text(cat),
              trailing: Text('\$${amt.toStringAsFixed(2)}'),
            ),
          );
        }).toList()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Budget Prediction"),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        user: widget.user,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(child: _buildBudgetList()),
      ),
    );
  }
}
