import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/pages/add_transaction_page.dart';
import 'package:wallet_watchers_app/pages/main_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Manager"),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          onPressed: () async {
            final transaction = await Navigator.push<Transaction>(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionPage(),
              ),
            );
            if (transaction != null) {
              _addTransaction(transaction);
            }
          },
          backgroundColor: Colors.blue[400],
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            CupertinoIcons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: MainScreen(transactions: transactions),
    );
  }
}
