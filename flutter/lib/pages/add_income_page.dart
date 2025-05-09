import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class AddIncomePage extends StatefulWidget {
  final ApiService apiService;
  const AddIncomePage({super.key, required this.apiService});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String? _name;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      await widget.apiService.addIncome(
        incomeAmount: _amount!,
        incomeName: _name!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Income added!')),
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
      appBar: AppBar(title: const Text('Add Income')),
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
                decoration: const InputDecoration(labelText: 'Income Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _name = v,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Add Income'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 