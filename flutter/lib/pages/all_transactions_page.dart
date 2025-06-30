import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/pages/add_expense_page.dart';
import 'package:wallet_watchers_app/pages/add_income_page.dart';

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
  
  // Track expanded transaction IDs
  Set<String> _expandedTransactions = {};

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
          SnackBar(
            content: Text('Error loading transactions: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleTransactionExpansion(String transactionId) {
    setState(() {
      if (_expandedTransactions.contains(transactionId)) {
        _expandedTransactions.remove(transactionId);
      } else {
        _expandedTransactions.add(transactionId);
      }
    });
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
                      direction: DismissDirection.horizontal,
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
                          // Swipe right - Edit
                          if (transaction.type == TransactionType.expense) {
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
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddIncomePage(
                                  apiService: _apiService,
                                  initialIncome: transaction,
                                ),
                              ),
                            );
                            if (result == true) {
                              await _loadTransactions();
                            }
                          }
                          return false; // Don't dismiss the item
                        } else {
                          // Swipe left - Delete
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(transaction.type == TransactionType.expense ? 'Delete Expense' : 'Delete Income'),
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
                          if (confirm == true) {
                          try {
                              if (transaction.type == TransactionType.expense) {
                            await _apiService.deleteExpense(widget.user.id, transaction.expenseName);
                              } else {
                                await _apiService.deleteIncome(widget.user.id, transaction.expenseName);
                              }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(transaction.type == TransactionType.expense ? 'Expense deleted successfully' : 'Income deleted successfully'),
                                    backgroundColor: Colors.green[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                              );
                              await _loadTransactions();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting ${transaction.type == TransactionType.expense ? 'expense' : 'income'}: $e'),
                                    backgroundColor: Colors.red[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                              );
                            }
                          }
                          }
                          return false;
                        }
                      },
                      child: GestureDetector(
                        onTap: () => _toggleTransactionExpansion(transaction.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
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
                            children: [
                                // Icon Container
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
                                
                                // Transaction Details - Flexible
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        transaction.expenseName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: _expandedTransactions.contains(transaction.id) 
                                            ? null 
                                            : TextOverflow.ellipsis,
                                        maxLines: _expandedTransactions.contains(transaction.id) 
                                            ? null 
                                            : 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (transaction.isBank) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.account_balance,
                                                    size: 12,
                                                    color: Colors.blue[700],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Bank',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Amount and Category - Fixed width with constraints
                                SizedBox(
                                  width: 100,
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${transaction.type == TransactionType.income ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: transaction.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                    ),
                                  ),
                                ],
                                  ),
                              ),
                            ],
                            ),
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