import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> transactions = [
    {"title": "Salary", "date": "Aug 25, 2025", "amount": 3000.00, "isIncome": true},
    {"title": "Rent", "date": "Aug 20, 2025", "amount": 1000.00, "isIncome": false},
    {"title": "Groceries", "date": "Aug 18, 2025", "amount": 200.00, "isIncome": false},
  ];

  void removeTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Income Manager"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "\$5,000.00",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text("No transactions yet"))
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Dismissible(
                    key: Key(transaction["title"]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      removeTransaction(index);
                    },
                    child: ListTile(
                      leading: Icon(
                        transaction["isIncome"] ? Icons.arrow_downward : Icons.arrow_upward,
                        color: transaction["isIncome"] ? Colors.green : Colors.red,
                      ),
                      title: Text(transaction["title"]),
                      subtitle: Text(transaction["date"]),
                      trailing: Text(
                        "${transaction["isIncome"] ? "+" : "-"}\$${transaction["amount"].toStringAsFixed(2)}",
                        style: TextStyle(
                          color: transaction["isIncome"] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
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
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}
