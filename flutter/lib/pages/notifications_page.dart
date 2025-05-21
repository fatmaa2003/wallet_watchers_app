import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/collaborative_goal.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<CollaborativeGoal>> _invitesFuture;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchInvites();
  }

  Future<void> _loadUserIdAndFetchInvites() async {
    final id = await _apiService.userId;
    print('Current User ID: $id');
    setState(() {
      _invitesFuture = _apiService.fetchInvites();
    });
  }

  Future<void> _respondToInvite(String goalId, String status) async {
    try {
      await _apiService.respondToInvite(goalId, status);
      setState(() {
        _invitesFuture = _apiService.fetchInvites();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to respond: $e")),
      );
    }
  }

  Widget _buildInviteCard(CollaborativeGoal goal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You're invited to: ${goal.title}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Target per user: ${goal.totalTargetPerUser.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text("Accept"),
                  onPressed: () => _respondToInvite(goal.id, 'accepted'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text("Reject"),
                  onPressed: () => _respondToInvite(goal.id, 'rejected'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<CollaborativeGoal>>(
        future: _invitesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final invites = snapshot.data ?? [];
          if (invites.isEmpty) {
            return const Center(
              child: Text(
                "No new invitations.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView(children: invites.map(_buildInviteCard).toList());
        },
      ),
    );
  }
}
