import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:uuid/uuid.dart';

class AddExpensePage extends StatefulWidget {
  final ApiService apiService;
  const AddExpensePage({super.key, required this.apiService});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String? _description;
  TransactionCategory? _category;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: _amount!,
        description: _description!,
        date: DateTime.now(),
        type: TransactionType.expense,
        category: _category!,
      );
      await widget.apiService.addExpense(transaction);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0
                    ? 'Enter a valid amount'
                    : null,
                onSaved: (v) => _amount = double.parse(v!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
                onSaved: (v) => _description = v,
              ),
              DropdownButtonFormField<TransactionCategory>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _category,
                items: TransactionCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (cat) => setState(() => _category = cat),
                validator: (cat) => cat == null ? 'Select a category' : null,
                onSaved: (cat) => _category = cat,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Add Expense'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 