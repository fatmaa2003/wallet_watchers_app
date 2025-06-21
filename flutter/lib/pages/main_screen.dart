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

  // Track expanded transaction IDs
  Set<String> _expandedTransactions = {};
  
  // Track expanded balance cards
  Set<String> _expandedBalanceCards = {};

  void _toggleTransactionExpansion(String transactionId) {
    setState(() {
      if (_expandedTransactions.contains(transactionId)) {
        _expandedTransactions.remove(transactionId);
      } else {
        _expandedTransactions.add(transactionId);
      }
    });
  }
  
  void _toggleBalanceCardExpansion(String cardType) {
    setState(() {
      if (_expandedBalanceCards.contains(cardType)) {
        _expandedBalanceCards.remove(cardType);
      } else {
        _expandedBalanceCards.add(cardType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    
    return Scaffold(
      endDrawer: CustomMenu(user: widget.user),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32.0 : isTablet ? 24.0 : 16.0, 
              vertical: 10
            ),
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
                            width: isTablet ? 55 : 45,
                            height: isTablet ? 55 : 45,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(CupertinoIcons.person_fill,
                                color: Colors.white, size: isTablet ? 24 : 20),
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello!',
                                    style: TextStyle(
                                        fontSize: isTablet ? 15 : 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey)),
                                Text(widget.user.fullName,
                                    style: TextStyle(
                                        fontSize: isTablet ? 22 : 18,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 6, 
                              vertical: isTablet ? 8 : 6),
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
                          child: Text(
                            'Wallet Bot',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12, 
                              color: Colors.black87
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        FloatingActionButton(
                          heroTag: 'chatBot',
                          tooltip: 'Open Wallet Bot',
                          mini: !isTablet,
                          backgroundColor: const Color(0xFF3A9EB7),
                          elevation: 2,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BotpressChatPage()),
                            );
                          },
                          child: Icon(Icons.smart_toy_outlined,
                              color: Colors.white, size: isTablet ? 22 : 18),
                        ),
                        SizedBox(width: isTablet ? 4 : 2),
                        Builder(
                          builder: (context) => IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.menu, size: isTablet ? 26 : 22),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 40 : 30),

                // Balance Card
                Container(
                  width: double.infinity,
                  height: isTablet ? 300 : 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 79, 161, 168),
                        Colors.blue[600]!
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
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
                      Text('Total Balance',
                          style: TextStyle(
                              fontSize: isTablet ? 20 : 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text('\$${totalBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: isTablet ? 40 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12, 
                            horizontal: isTablet ? 32 : 20),
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

                SizedBox(height: isTablet ? 50 : 40),

                // Recent Transactions Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
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
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 24 : 20),

                // List of Transactions
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  itemCount: widget.transactions.length > (isTablet ? 15 : 10) ? (isTablet ? 15 : 10) : widget.transactions.length,
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
                        padding: EdgeInsets.only(right: isTablet ? 24 : 20),
                        child: Icon(
                          Icons.edit_outlined,
                          color: Colors.green,
                          size: isTablet ? 36 : 30,
                        ),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: isTablet ? 24 : 20),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: isTablet ? 36 : 30,
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
                                SnackBar(
                                  content: const Text('Expense deleted successfully'),
                                  backgroundColor: Colors.green[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              );
                              if (widget.refreshTransactions != null) {
                                await widget.refreshTransactions!();
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting expense: $e'),
                                  backgroundColor: Colors.red[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: GestureDetector(
                        onTap: () => _toggleTransactionExpansion(t.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(bottom: isTablet ? 20.0 : 16.0),
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
                            padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  width: isTablet ? 60 : 50,
                                  height: isTablet ? 60 : 50,
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
                                  child: Icon(t.icon, color: t.color, size: isTablet ? 28 : 24),
                                ),
                                SizedBox(width: isTablet ? 20 : 16),
                                
                                // Transaction Details - Flexible
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        t.expenseName,
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: _expandedTransactions.contains(t.id) 
                                            ? null 
                                            : TextOverflow.ellipsis,
                                        maxLines: _expandedTransactions.contains(t.id) 
                                            ? null 
                                            : 1,
                                      ),
                                      SizedBox(height: isTablet ? 6 : 4),
                                      Text(
                                        '${t.date.day}/${t.date.month}/${t.date.year}',
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Amount and Category - Fixed width with constraints
                                SizedBox(
                                  width: isTablet ? 120 : 100,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${t.type == TransactionType.income ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          color: t.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: isTablet ? 6 : 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isTablet ? 10 : 8,
                                          vertical: isTablet ? 6 : 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: t.color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          t.category.categoryName.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            color: t.color,
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
                
                // Bottom padding to prevent FAB from hiding content
                SizedBox(height: isTablet ? 120 : 100),
              ],
            ),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    
    return GestureDetector(
      onTap: () => _toggleBalanceCardExpansion(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isDesktop ? 180 : isTablet ? 160 : 150,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16, 
          vertical: isTablet ? 20 : 16
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
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
                  width: isTablet ? 44 : 36,
                  height: isTablet ? 44 : 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: isTablet ? 22 : 18, color: color),
                ),
                SizedBox(width: isTablet ? 10 : 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: _expandedBalanceCards.contains(title) 
                        ? null 
                        : TextOverflow.ellipsis,
                    maxLines: _expandedBalanceCards.contains(title) 
                        ? null 
                        : 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: _expandedBalanceCards.contains(title) 
                  ? null 
                  : TextOverflow.ellipsis,
              maxLines: _expandedBalanceCards.contains(title) 
                  ? null 
                  : 1,
            ),
          ],
        ),
      ),
    );
  }
}
