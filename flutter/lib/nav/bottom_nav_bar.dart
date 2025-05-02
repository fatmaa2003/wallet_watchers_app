import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/pages/home_page.dart';
import 'package:wallet_watchers_app/pages/statistics_page.dart';
import 'package:wallet_watchers_app/pages/profile_page.dart';
import 'package:wallet_watchers_app/pages/ReceiptScanPage.dart';
import 'package:wallet_watchers_app/pages/goals_page.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const StatisticsPage();
        break;
      case 2:
        page = const GoalsPage();
        break;
      case 3:
        page = const ReceiptScanPage();
        break;
      case 4:
        page = const ProfilePage();
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
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[600],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), label: "Statistics"),
        BottomNavigationBarItem(
            icon: Icon(Icons.flag), label: "Goals"), // 👈 Label for Goals
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Scan"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
