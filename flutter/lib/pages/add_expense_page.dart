import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:uuid/uuid.dart';

class AddExpensePage extends StatefulWidget {
  final ApiService apiService;
  final Transaction? initialExpense;

  const AddExpensePage({
    super.key,
    required this.apiService,
    this.initialExpense,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionCategory _selectedCategory = TransactionCategory.Food;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialExpense != null) {
      _amountController.text = widget.initialExpense!.amount.toString();
      _descriptionController.text = widget.initialExpense!.expenseName;
      _selectedCategory = widget.initialExpense!.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final transaction = Transaction(
        id: widget.initialExpense?.id ?? const Uuid().v4(),
        amount: double.parse(_amountController.text),
        expenseName: _descriptionController.text,
        category: _selectedCategory,
        type: TransactionType.expense,
        date: widget.initialExpense?.date ?? DateTime.now(),
      );

      if (widget.initialExpense != null) {
        await widget.apiService.updateExpense(transaction);
      } else {
        await widget.apiService.addExpense(transaction);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.Food:
        return Icons.restaurant;
      case TransactionCategory.Transportation:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.bills:
        return Icons.receipt;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.Food:
        return Colors.orange;
      case TransactionCategory.Transportation:
        return Colors.blue;
      case TransactionCategory.shopping:
        return Colors.pink;
      case TransactionCategory.bills:
        return Colors.red;
      case TransactionCategory.entertainment:
        return Colors.purple;
      case TransactionCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.initialExpense != null ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0
                        ? 'Enter a valid amount'
                        : null,
                    controller: _amountController,
                  ),
                ),
                const SizedBox(height: 24),

                // Description Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
                    controller: _descriptionController,
                  ),
                ),
                const SizedBox(height: 24),

                // Category Selection
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<TransactionCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: TransactionCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              color: _getCategoryColor(category),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                    validator: (cat) => cat == null ? 'Select a category' : null,
                  ),
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.initialExpense != null ? 'Update Expense' : 'Add Expense',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 