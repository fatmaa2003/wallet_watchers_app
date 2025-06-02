import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/models/category.dart';
import 'package:wallet_watchers_app/providers/categories_provider.dart';
import 'package:provider/provider.dart';
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
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialExpense != null) {
      _amountController.text = widget.initialExpense!.amount.toString();
      _descriptionController.text = widget.initialExpense!.expenseName;
      // Don't set the category here, wait for categories to load
    }
    // Load categories when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CategoriesProvider>().loadCategories();
      if (widget.initialExpense != null && mounted) {
        // Find matching category after categories are loaded
        final categories = context.read<CategoriesProvider>().categories;
        final matchingCategory = categories.firstWhere(
          (cat) => cat.categoryName.toLowerCase() == widget.initialExpense!.category.categoryName.toLowerCase(),
          orElse: () => categories.first,
        );
        setState(() {
          _selectedCategory = matchingCategory;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = Transaction(
        id: widget.initialExpense?.id ?? const Uuid().v4(),
        amount: double.parse(_amountController.text),
        expenseName: _descriptionController.text,
        category: _selectedCategory!,
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

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('food')) return Icons.restaurant;
    if (name.contains('transport')) return Icons.directions_car;
    if (name.contains('shop')) return Icons.shopping_bag;
    if (name.contains('bill')) return Icons.receipt;
    if (name.contains('entertain')) return Icons.movie;
    return Icons.more_horiz;
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('food')) return Colors.orange;
    if (name.contains('transport')) return Colors.blue;
    if (name.contains('shop')) return Colors.pink;
    if (name.contains('bill')) return Colors.red;
    if (name.contains('entertain')) return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.watch<CategoriesProvider>();
    final categories = categoriesProvider.categories;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.initialExpense != null ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: categoriesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        child: DropdownButtonFormField<Category>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(category.categoryName),
                                    color: _getCategoryColor(category.categoryName),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    category.categoryName,
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
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.initialExpense != null ? 'Update Expense' : 'Add Expense',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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