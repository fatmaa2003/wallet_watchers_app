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
        print("📦 Loaded saved budget on load: ${budgets.first}");
      } else {
        print("❗ No saved budgets found for this user.");
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

      print("🧠 Backend result: $result");

      final message = result['message'] ?? 'Budget processed.';
      final budget = result['budget'];

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      // ✅ Only update budgetData if a valid budget is returned
      if (budget != null &&
          budget['total'] != null &&
          budget['byCategory'] != null &&
          budget['byCategory'] is List) {
        print("💾 Updating displayed budget");
        setState(() {
          _budgetData = budget;
        });
      } else {
        print("✅ Message shown, keeping existing budget on screen");
        // Don't clear the UI — retain the previous _budgetData
      }

      // ✅ Optional: Show AI alert if enough history exists
      if ((budget?['historyLength'] ?? 0) >= 3) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("📊 Data Insight"),
            content: const Text(
              "You have at least 3 months of historical data. This helps AI improve its predictions.",
            ),
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
      print("❌ Exception in _generateBudget: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildBudgetList() {
    print("📦 Rendering budget data: $_budgetData");

    if (_budgetData == null) {
      return const Center(
        child: Text("No budget data available. Click the button to generate."),
      );
    }

    final categoryList = (_budgetData!['byCategory'] as List?) ?? [];
    final total = _budgetData!['total'] ?? 0.0;
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
          "Category Limits:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...categoryList.map((item) {
          final cat = item['category'] ?? 'Unknown';
          final amt = item['amount'] ?? 0.0;
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
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.smart_toy_outlined),
                      label: const Text("Generate Budget for Next Month"),
                      onPressed: _generateBudget,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildBudgetList(),
                  ],
                ),
              ),
      ),
    );
  }
}
