import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/pages/add_expense_page.dart';
import 'package:wallet_watchers_app/pages/main_screen.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      print('Fetching expenses for userId: \\${widget.user.id}');
      final expenses = await _apiService.fetchExpenses(widget.user.id);
      print('Fetching incomes for userId: \\${widget.user.id}');
      final incomes = await _apiService.fetchIncomes(widget.user.id);
      final all = [...expenses, ...incomes];
      all.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
      setState(() {
        transactions = all;
      });
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Wallet Watchers"),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0, user: widget.user),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : MainScreen(
              transactions: transactions,
              user: widget.user,
              refreshTransactions: _loadTransactions,
            ),
    );
  }
}
