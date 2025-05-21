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
  void initState() {
    super.initState();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("New Collaborative Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Goal Title"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount per User"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (title.isNotEmpty && amount > 0) {
                await _apiService.createCollaborativeGoal(title, amount);
                _loadGoals();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...goal.participants.map((p) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "${p.name}: ${p.savedAmount.toStringAsFixed(2)} / ${goal.totalTargetPerUser} (${p.status})"),
                    LinearProgressIndicator(
                      value: (p.savedAmount / goal.totalTargetPerUser)
                          .clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                  ],
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCreator)
                  TextButton.icon(
                    icon: const Icon(Icons.group_add),
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
                    icon: const Icon(Icons.exit_to_app),
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
              child: TextButton.icon(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Invite Friend"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Friend's Email"),
        ),
        actions: [
          TextButton(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Update Your Contribution"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
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
      appBar: AppBar(
        title: const Text("Collaborative Goals"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: _showAddGoalDialog),
        ],
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
    );
  }
}
