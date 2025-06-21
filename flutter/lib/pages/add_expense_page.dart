import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:wallet_watchers_app/models/category.dart';
import 'package:wallet_watchers_app/providers/categories_provider.dart';
import 'package:wallet_watchers_app/pages/ReceiptScanPage.dart';

class AddExpensePage extends StatefulWidget {
  final ApiService apiService;
  final Transaction? initialExpense;
  const AddExpensePage({super.key, required this.apiService, this.initialExpense});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String? _expenseName;
  Category? _category;
  DateTime? _date;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
    if (categoriesProvider.categories.isEmpty && !categoriesProvider.isLoading) {
      categoriesProvider.loadCategories();
    }
    if (widget.initialExpense != null) {
      _amount = widget.initialExpense!.amount;
      _expenseName = widget.initialExpense!.expenseName;
      _date = widget.initialExpense!.date;
    } else {
      _date = DateTime.now();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submit() async {
    print('DEBUG: initialExpense: \\${widget.initialExpense}');
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      final transaction = Transaction(
        id: widget.initialExpense?.id ?? const Uuid().v4(),
        amount: _amount!,
        expenseName: _expenseName!,
        date: _date!,
        type: TransactionType.expense,
        category: _category!,
      );
      print('DEBUG: Submitting transaction: \\${transaction.toJson()}');
      if (widget.initialExpense != null) {
        await widget.apiService.updateExpense(transaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Expense updated!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } else {
        await widget.apiService.addExpense(
          expenseName: transaction.expenseName,
          amount: transaction.amount,
          category: transaction.category,
          date: transaction.date,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Expense added!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.0 : isTablet ? 28.0 : 24.0),
          child: Consumer<CategoriesProvider>(
            builder: (context, categoriesProvider, _) {
              if (categoriesProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (categoriesProvider.error != null) {
                return Center(child: Text('Error: ${categoriesProvider.error}'));
              }
              final categories = categoriesProvider.categories;

              // Ensure _category is the same instance as in categories list
              if (_category == null && widget.initialExpense != null && categories.isNotEmpty) {
                final match = categories.firstWhere(
                  (cat) => cat.id == widget.initialExpense!.category.id,
                  orElse: () => categories.first,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _category = match);
                });
              }

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Input
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16, 
                        vertical: isTablet ? 12 : 8
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                        initialValue: _amount?.toString(),
                        validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0
                            ? 'Enter a valid amount'
                            : null,
                        onSaved: (v) => _amount = double.parse(v!),
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Expense Name Input
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16, 
                        vertical: isTablet ? 12 : 8
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
                          labelText: 'Expense Name',
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        initialValue: _expenseName,
                        validator: (v) => v == null || v.isEmpty ? 'Enter an expense name' : null,
                        onSaved: (v) => _expenseName = v,
                        enabled: widget.initialExpense == null,
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Date Picker
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16, 
                        vertical: isTablet ? 12 : 8
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Date',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _date != null ? _date!.toLocal().toString().split(' ')[0] : '',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            size: isTablet ? 24 : 20,
                          ),
                          onPressed: widget.initialExpense == null ? _pickDate : null,
                        ),
                        onTap: widget.initialExpense == null ? _pickDate : null,
                        enabled: widget.initialExpense == null,
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Category Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16, 
                        vertical: isTablet ? 12 : 8
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<Category>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        value: _category,
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat.categoryName,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: widget.initialExpense == null ? (cat) => setState(() => _category = cat) : null,
                        validator: (cat) => cat == null ? 'Select a category' : null,
                        onSaved: (cat) => _category = cat,
                        disabledHint: _category != null ? Text(
                          _category!.categoryName,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ) : null,
                      ),
                    ),
                    SizedBox(height: isTablet ? 50 : 40),

                    // Receipt Scanning Button (only show when adding new expense)
                    if (widget.initialExpense == null) ...[
                      Container(
                        width: double.infinity,
                        height: isTablet ? 64 : 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[200]!,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReceiptScanPage(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.document_scanner,
                            size: isTablet ? 24 : 20,
                            color: Colors.blue[600],
                          ),
                          label: Text(
                            'Scan Receipt',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                              side: BorderSide(color: Colors.blue[200]!, width: 1),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : 20),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 64 : 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: isTablet ? 28 : 24,
                                height: isTablet ? 28 : 24,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.initialExpense != null ? 'Update Expense' : 'Add Expense',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 