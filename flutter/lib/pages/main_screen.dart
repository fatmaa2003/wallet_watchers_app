import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/pages/botpress_chat_page.dart';
import 'package:wallet_watchers_app/menu/custom_menu.dart';
import 'package:wallet_watchers_app/pages/add_expense_page.dart';
import 'package:wallet_watchers_app/pages/add_income_page.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:wallet_watchers_app/pages/all_transactions_page.dart';

class MainScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final User user;
  final Future<void> Function()? refreshTransactions;

  const MainScreen({
    super.key,
    required this.transactions,
    required this.user,
    this.refreshTransactions,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double get totalBalance => widget.transactions.fold(
      0,
      (sum, t) =>
          sum + (t.type == TransactionType.income ? t.amount : -t.amount));
  double get totalIncome => widget.transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);
  double get totalExpenses => widget.transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    return Scaffold(
      endDrawer: CustomMenu(user: widget.user),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              // Header: User Info and Right Side Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: User Info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.person_fill,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hello!',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey)),
                              Text(widget.user.fullName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Message + Chatbot Icon + Menu Icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Wallet Bot',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      FloatingActionButton(
                        heroTag: 'chatBot',
                        tooltip: 'Open Wallet Bot',
                        mini: true,
                        backgroundColor: const Color(0xFF3A9EB7),
                        elevation: 2,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BotpressChatPage()),
                          );
                        },
                        child: const Icon(Icons.smart_toy_outlined,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 2),
                      Builder(
                        builder: (context) => IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.menu, size: 22),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Balance Card
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 79, 161, 168),
                      Colors.blue[600]!
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[200]!.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Balance',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('\$${totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceCard('Income', totalIncome,
                              CupertinoIcons.arrow_up, Colors.green[400]!),
                          _buildBalanceCard('Expenses', totalExpenses,
                              CupertinoIcons.arrow_down, Colors.red[400]!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Recent Transactions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllTransactionsPage(user: widget.user),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.blue[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // List of Transactions
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.transactions.length > 10 ? 10 : widget.transactions.length,
                  itemBuilder: (context, index) {
                    final t = widget.transactions[index];
                    return Dismissible(
                      key: Key(t.id),
                      direction: t.type == TransactionType.expense ? DismissDirection.horizontal : DismissDirection.none,
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
                                apiService: ApiService(),
                                initialExpense: t,
                              ),
                            ),
                          );
                          if (result == true && widget.refreshTransactions != null) {
                            await widget.refreshTransactions!();
                          }
                          return false; // Don't dismiss the item
                        } else {
                          // Swipe left - Delete expense
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Expense'),
                              content: Text('Are you sure you want to delete "${t.expenseName}"?'),
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
                            final apiService = ApiService();
                            await apiService.deleteExpense(widget.user.id, t.expenseName);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expense deleted successfully')),
                              );
                              if (widget.refreshTransactions != null) {
                                await widget.refreshTransactions!();
                              }
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
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            t.color.withOpacity(0.2),
                                            t.color.withOpacity(0.1)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(t.icon, color: t.color),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(t.expenseName,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Text(
                                              '${t.date.day}/${t.date.month}/${t.date.year}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${t.type == TransactionType.income ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: t.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: t.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      t.category.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: t.color,
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEF5350),
                        child: Icon(Icons.remove_circle_outline, color: Colors.white),
                      ),
                      title: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddExpensePage(apiService: apiService),
                          ),
                        );
                        if (result == true && widget.refreshTransactions != null) {
                          await widget.refreshTransactions!();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF66BB6A),
                        child: Icon(Icons.add_circle_outline, color: Colors.white),
                      ),
                      title: const Text('Add Income', style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddIncomePage(apiService: apiService),
                          ),
                        );
                        if (result == true && widget.refreshTransactions != null) {
                          await widget.refreshTransactions!();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Colors.blue[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceCard(
      String title, double amount, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
