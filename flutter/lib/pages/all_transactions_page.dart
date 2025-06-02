import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/pages/add_expense_page.dart';

class AllTransactionsPage extends StatefulWidget {
  final User user;
  const AllTransactionsPage({super.key, required this.user});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  final ApiService _apiService = ApiService();
  List<Transaction> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await _apiService.fetchExpenses(widget.user.id);
      final incomes = await _apiService.fetchIncomes(widget.user.id);
      
      setState(() {
        _allTransactions = [...expenses, ...incomes];
        _allTransactions.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _allTransactions[index];
                    return Dismissible(
                      key: Key(transaction.id),
                      direction: transaction.type == TransactionType.expense
                          ? DismissDirection.horizontal
                          : DismissDirection.none,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Swipe right - Edit expense
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpensePage(
                                apiService: _apiService,
                                initialExpense: transaction,
                              ),
                            ),
                          );
                          if (result == true) {
                            await _loadTransactions();
                          }
                          return false; // Don't dismiss the item
                        } else {
                          // Swipe left - Delete expense
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Expense'),
                              content: Text('Are you sure you want to delete "${transaction.expenseName}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          try {
                            await _apiService.deleteExpense(widget.user.id, transaction.expenseName);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expense deleted successfully')),
                              );
                              await _loadTransactions();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting expense: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          transaction.color.withOpacity(0.2),
                                          transaction.color.withOpacity(0.1)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(transaction.icon, color: transaction.color),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.expenseName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${transaction.type == TransactionType.income ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: transaction.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: transaction.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      transaction.category.categoryName.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: transaction.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0, user: widget.user),
    );
  }
} 