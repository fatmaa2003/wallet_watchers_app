import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String? _message;

  @override
  void initState() {
    super.initState();
    _fetchLatestBudgetOnLoad();
  }

  Future<void> _fetchLatestBudgetOnLoad() async {
    setState(() => _isLoading = true);
    try {
      final service = BudgetService();
      final budgets = await service.fetchSavedBudgets();
      if (budgets.isNotEmpty) {
        setState(() {
          _budgetData = budgets.first;
        });
      }
    } catch (e) {
      debugPrint("❌ Failed to load saved budget: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateBudget() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final service = BudgetService();
      final result = await service.generateBudget();
      final message = result['message'] ?? 'Budget processed.';
      final budget = result['budget'];

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));

      if (budget != null &&
          budget['total'] != null &&
          budget['byCategory'] is List) {
        setState(() {
          _budgetData = budget;
        });
      }

      if ((budget?['historyLength'] ?? 0) >= 3) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("📊 Data Insight"),
            content: const Text(
                "You have at least 3 months of historical data. This helps AI improve its predictions."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildBudgetList() {
    if (_budgetData == null) {
      return const Center(
        child: Text("No budget data available. Click the button to generate."),
      );
    }

    final categoryList = (_budgetData!['byCategory'] as List?) ?? [];
    final total = _budgetData!['total'] ?? 0.0;
    final predictedMonth = _budgetData!['predictedMonth'] ?? '';
    final currentMonthFormatted =
        DateFormat('MMMM yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AI Predicted Budget for $currentMonthFormatted  $predictedMonth",
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
        ),
        const SizedBox(height: 12),
        Text(
          "Total Spending Limit: \$${total.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          "Category Limits:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...categoryList.map((item) {
          final cat = item['category'] ?? 'Unknown';
          final amt = item['amount'] ?? 0.0;
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading:
                  const Icon(Icons.pie_chart_outline, color: Colors.blueAccent),
              title: Text(cat,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("AI Budget Prediction"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        user: widget.user,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.smart_toy_outlined),
                      label: const Text("Generate Budget for Next Month"),
                      onPressed: _generateBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildBudgetList(),
                  ],
                ),
              ),
      ),
    );
  }
}
