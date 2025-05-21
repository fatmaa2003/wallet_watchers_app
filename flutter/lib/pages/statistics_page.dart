import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wallet_watchers_app/pages/add_expense_page.dart';

class StatisticsPage extends StatefulWidget {
  final User user;
  const StatisticsPage({super.key, required this.user});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Transaction> _selectedDayTransactions = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTransactionsForDate(_selectedDay);
  }

  Future<void> _loadTransactionsForDate(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      final expenses = await _apiService.getExpensesByDate(widget.user.id, date);
      setState(() {
        _selectedDayTransactions = expenses;
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
        title: const Text("Daily Expenses"),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
      ),
      body: Column(
            children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadTransactionsForDate(selectedDay);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue[400],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue[200],
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Title Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Transactions for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Selected Day Transactions
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedDayTransactions.isEmpty
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
                              "No transactions for ${_selectedDay.toString().split(' ')[0]}",
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
                        itemCount: _selectedDayTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _selectedDayTransactions[index];
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
                                  await _loadTransactionsForDate(_selectedDay);
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
                                    await _loadTransactionsForDate(_selectedDay);
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
                                            transaction.category.name.toUpperCase(),
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
        ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 1, user: widget.user),
    );
  }
}