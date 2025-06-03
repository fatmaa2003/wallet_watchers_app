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
  bool _isBank = false;
  final _bankNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();
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
    _bankNameController.dispose();
    _cardNumberController.dispose();
    _accountNumberController.dispose();
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
        final apiService = Provider.of<ApiService>(context, listen: false);
        await apiService.addExpense(
          expenseName: _nameController.text,
          amount: double.parse(_amountController.text),
          category: _selectedCategory!,
          date: _selectedDate,
          isBank: _isBank,
          bankName: _isBank ? _bankNameController.text : null,
          cardNumber: _isBank ? _formatCardNumber(_cardNumberController.text) : null,
          accountNumber: _isBank ? _accountNumberController.text : null,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding expense: $e')),
          );
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
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
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
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.categoryName),
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
                      SwitchListTile(
                        title: const Text('Bank Transaction'),
                        value: _isBank,
                        onChanged: (bool value) {
                          setState(() {
                            _isBank = value;
                          });
                        },
                      ),
                      if (_isBank) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bankNameController,
                          decoration: const InputDecoration(
                            labelText: 'Bank Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_isBank && (value == null || value.isEmpty)) {
                              return 'Please enter a bank name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Card Number (XXXX-XXXX-XXXX-XXXX)',
                            border: OutlineInputBorder(),
                            hintText: '1234-5678-9876-5432',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_isBank && (value == null || value.isEmpty)) {
                              return 'Please enter a card number';
                            }
                            if (_isBank && value != null && value.isNotEmpty) {
                              // Remove any non-digit characters for validation
                              String digits = value.replaceAll(RegExp(r'[^\d]'), '');
                              if (digits.length != 16) {
                                return 'Card number must be 16 digits';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _accountNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Account Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_isBank && (value == null || value.isEmpty)) {
                              return 'Please enter an account number';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitExpense,
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