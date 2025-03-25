import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/nav/bottom_nav_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with actual image
                ),
                const SizedBox(height: 10),
                const Text(
                  "John Doe",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                const Text(
                  "johndoe@example.com",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.deepPurple),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.deepPurple),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.deepPurple),
            title: const Text("Notifications"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Handle logout
            },
          ),
          const Spacer(),
          const Text(
            "Wallet Watchers © 2025",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }
}