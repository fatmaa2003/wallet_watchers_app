import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/transaction.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';
import 'package:wallet_watchers_app/pages/add_transaction_page.dart';
import 'package:wallet_watchers_app/pages/main_screen.dart';
import 'package:wallet_watchers_app/pages/botpress_chat_page.dart';

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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'addTransaction',
              tooltip: 'Add Transaction',
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
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'chatBot',
              tooltip: 'Chat Assistant',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BotpressChatPage(),
                  ),
                );
              },
              backgroundColor: Colors.green,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: MainScreen(transactions: transactions),
    );
  }
}
