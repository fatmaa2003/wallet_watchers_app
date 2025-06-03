import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/models/category.dart';
import 'package:wallet_watchers_app/providers/categories_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (widget.initialExpense != null) {
      _amountController.text = widget.initialExpense!.amount.toString();
      _nameController.text = widget.initialExpense!.expenseName;
      _selectedDate = widget.initialExpense!.date;
      _selectedCategory = widget.initialExpense!.category;
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
    await categoriesProvider.loadCategories();
    if (mounted) {
      setState(() {
        _selectedCategory = categoriesProvider.categories.firstOrNull;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  String _formatCardNumber(String input) {
    // Remove any non-digit characters
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format as XXXX-XXXX-XXXX-XXXX
    if (digits.length > 16) {
      digits = digits.substring(0, 16);
    }
    
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += '-';
      }
      formatted += digits[i];
    }
    
    return formatted;
  }

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      try {
        setState(() => _isLoading = true);
        final apiService = Provider.of<ApiService>(context, listen: false);
        await apiService.addExpense(
          expenseName: _nameController.text,
          amount: double.parse(_amountController.text),
          category: _selectedCategory!,
          date: _selectedDate,
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding expense: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialExpense != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expense name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              Consumer<CategoriesProvider>(
                builder: (context, categoriesProvider, child) {
                  return DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categoriesProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category.categoryName),
                              color: _getCategoryColor(category.categoryName),
                            ),
                            const SizedBox(width: 8),
                            Text(category.categoryName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitExpense,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.initialExpense != null ? 'Update Expense' : 'Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 