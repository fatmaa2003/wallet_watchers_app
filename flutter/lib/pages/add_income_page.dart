import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:uuid/uuid.dart';

class AddIncomePage extends StatefulWidget {
  final ApiService apiService;
  final Transaction? initialIncome;
  const AddIncomePage({super.key, required this.apiService, this.initialIncome});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String? _description;
  DateTime? _date;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialIncome != null) {
      _amount = widget.initialIncome!.amount;
      _description = widget.initialIncome!.expenseName;
      _date = widget.initialIncome!.date;
    } else {
      _date = DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      if (widget.initialIncome != null) {
        // Update income
        final updatedIncome = Transaction(
          id: widget.initialIncome!.id,
          amount: _amount!,
          expenseName: _description!,
          date: _date!,
          type: TransactionType.income,
          category: widget.initialIncome!.category,
          isBank: widget.initialIncome!.isBank,
          bankName: widget.initialIncome!.bankName,
          cardNumber: widget.initialIncome!.cardNumber,
          accountNumber: widget.initialIncome!.accountNumber,
        );
        await widget.apiService.updateIncome(
          widget.apiService.userId,
          updatedIncome,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Income updated!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Add income
      await widget.apiService.addIncome(
        incomeAmount: _amount!,
        incomeName: _description!,
          date: _date!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Income added!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
        );
        Navigator.pop(context, true);
        }
      }
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
        title: Text(widget.initialIncome != null ? 'Edit Income' : 'Add Income'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.0 : isTablet ? 28.0 : 24.0),
          child: Form(
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

                // Description Input
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
                      labelText: 'Description',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    initialValue: _description,
                    validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
                    onSaved: (v) => _description = v,
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24),

                // Date Input
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
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.grey),
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                      ),
                      child: Text(
                        _date != null 
                            ? '${_date!.day}/${_date!.month}/${_date!.year}'
                            : 'Select Date',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: _date != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 50 : 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 64 : 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
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
                            widget.initialIncome != null ? 'Update Income' : 'Add Income',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
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