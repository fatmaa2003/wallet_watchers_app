import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/collaborative_goal.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class CollaborativeGoalsPage extends StatefulWidget {
  const CollaborativeGoalsPage({Key? key}) : super(key: key);

  @override
  State<CollaborativeGoalsPage> createState() => _CollaborativeGoalsPageState();
}

class _CollaborativeGoalsPageState extends State<CollaborativeGoalsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<CollaborativeGoal>> _goalsFuture;
  String? _currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final userId = await _apiService.userId;
    setState(() {
      _currentUserId = userId;
      _goalsFuture = _apiService.fetchCollaborativeGoals();
    });
  }

  Future<void> _showAddGoalDialog() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("New Collaborative Goal",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Goal Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: "Amount per User",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Create Goal"),
            onPressed: () async {
              final title = titleController.text.trim();
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (title.isNotEmpty && amount > 0) {
                await _apiService.createCollaborativeGoal(title, amount);
                _loadGoals();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(CollaborativeGoal goal) {
    final bool isCreator = goal.createdBy == _currentUserId;
    final currentUser = goal.participants.firstWhere(
      (p) => p.userId == _currentUserId,
      orElse: () => Participant(
        userId: "",
        name: "You",
        savedAmount: 0,
        status: "accepted",
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...goal.participants
                .where((p) => p.status == 'accepted')
                .map((p) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${p.name}: ${p.savedAmount.toStringAsFixed(2)} / ${goal.totalTargetPerUser}",
                          style: const TextStyle(color: Colors.black87),
                        ),
                        LinearProgressIndicator(
                          value: (p.savedAmount / goal.totalTargetPerUser)
                              .clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          color: Colors.lightBlueAccent,
                        ),
                        const SizedBox(height: 8),
                      ],
                    )),
            if (isCreator)
              ...goal.participants
                  .where((p) =>
                      p.status == 'accepted' && p.userId != _currentUserId)
                  .map((p) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.name,
                              style: const TextStyle(color: Colors.black87)),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () async {
                              await _apiService.removeFriend(goal.id, p.userId);
                              _loadGoals();
                            },
                          )
                        ],
                      )),
            const Divider(color: Colors.black26),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCreator)
                  TextButton.icon(
                    icon: const Icon(Icons.group_add, color: Colors.blue),
                    label: const Text("Add Friend"),
                    onPressed: () => _showAddFriendDialog(goal.id),
                  ),
                if (isCreator)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("Delete Goal",
                        style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      await _apiService.deleteCollaborativeGoal(goal.id);
                      _loadGoals();
                    },
                  ),
                if (!isCreator)
                  TextButton.icon(
                    icon: const Icon(Icons.exit_to_app, color: Colors.blue),
                    label: const Text("Leave Goal"),
                    onPressed: () async {
                      await _apiService.leaveGoal(goal.id);
                      _loadGoals();
                    },
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                icon: const Icon(Icons.edit),
                label: const Text("Update My Amount"),
                onPressed: () => _showUpdateContributionDialog(
                    goal.id, currentUser.savedAmount),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddFriendDialog(String goalId) async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Invite Friend"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: "Friend's Email",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                await _apiService.addFriendToGoal(goalId, email);
                _loadGoals();
                Navigator.pop(context);
              }
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateContributionDialog(
      String goalId, double current) async {
    final amountController = TextEditingController(text: current.toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Your Contribution"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            onPressed: () async {
              final amount =
                  double.tryParse(amountController.text.trim()) ?? current;
              await _apiService.updateContribution(goalId, amount);
              _loadGoals();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Collaborative Goals"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: FutureBuilder<List<CollaborativeGoal>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final goals = snapshot.data ?? [];
          if (goals.isEmpty) {
            return const Center(child: Text("No collaborative goals yet."));
          }
          return ListView(children: goals.map(_buildGoalCard).toList());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        backgroundColor: Colors.lightBlueAccent,
        icon: const Icon(Icons.add),
        label: const Text("New Collaborative Goal"),
      ),
    );
  }
}
