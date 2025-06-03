import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/pages/goals_page.dart';
import 'package:wallet_watchers_app/pages/profile_page.dart';
import 'package:wallet_watchers_app/pages/collaborative_goals_page.dart';
import 'package:wallet_watchers_app/pages/notifications_page.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class CustomMenu extends StatefulWidget {
  final User user;

  const CustomMenu({super.key, required this.user});

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  final ApiService _apiService = ApiService();
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final count = await _apiService.getPendingInvitesCount();
      print("Notifications count: $count");
      setState(() {
        _notificationCount = count;
      });
    } catch (e) {
      print("Error loading notification count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Profile Page
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user),
                ),
              );
            },
          ),

          // Notifications Page
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications'),
                if (_notificationCount > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsPage()),
              );
              _loadNotificationCount(); // refresh after returning
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
                MaterialPageRoute(
                  builder: (context) => GoalsPage(user: widget.user),
                ),
              );
            },
          ),

          // Collaborative Goals Page
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Collaborative Goals'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CollaborativeGoalsPage(),
                ),
              );
            },
          ),

          // Contact Us
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              // Future implementation
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
