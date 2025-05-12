import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/pages/home_page.dart';
import 'package:wallet_watchers_app/pages/statistics_page.dart';
import 'package:wallet_watchers_app/pages/budget_page.dart'; // ✅ Import BudgetPage
import 'package:wallet_watchers_app/models/user.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final User user;

  const BottomNavBar({super.key, required this.selectedIndex, required this.user});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = HomePage(user: user);
        break;
      case 1:
        page = StatisticsPage(user: user);
        break;
      case 2:
        page = BudgetPage(user: user); // ✅ Add BudgetPage (no user param unless you modify the page)
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.home_outlined,
      Icons.bar_chart_outlined,
      Icons.account_balance_wallet_outlined, // ✅ Budget icon
    ];

    List<String> labels = ['Home', 'Statistics', 'Budget'];

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => _onItemTapped(context, index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(4),
                  decoration: isSelected
                      ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade100,
                  )
                      : null,
                  child: Icon(
                    icons[index],
                    size: 24,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  labels[index],
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
