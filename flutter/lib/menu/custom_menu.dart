import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/pages/goals_page.dart';
import 'package:wallet_watchers_app/pages/profile_page.dart';

class CustomMenu extends StatelessWidget {
  const CustomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          // Profile Page
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          // Notifications (placeholder)
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              // Implement later
            },
          ),

          // Goals Page
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Goals'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalsPage()),
              );
            },
          ),

          // Contact Us (placeholder)
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              // Implement later
            },
          ),
        ],
      ),
    );
  }
}
