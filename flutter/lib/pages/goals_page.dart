import 'package:flutter/material.dart';
import 'package:wallet_watchers_app/models/goal.dart';
import 'package:wallet_watchers_app/models/user.dart';
import 'package:wallet_watchers_app/pages/home_page.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class GoalsPage extends StatefulWidget {
  final User user;
  const GoalsPage({super.key, required this.user});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Goal>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _goalsFuture = _apiService.fetchGoals();
  }

  void _refreshGoals() {
    setState(() {
      _goalsFuture = _apiService.fetchGoals();
    });
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final savedController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Goal'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: savedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saved Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.flag),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            onPressed: () async {
              final goal = Goal(
                id: '',
                title: titleController.text.trim(),
                icon: 'flag',
                savedAmount: double.tryParse(savedController.text.trim()) ?? 0,
                targetAmount:
                    double.tryParse(targetController.text.trim()) ?? 0,
                isAchieved: false,
              );

              try {
                await _apiService.createGoal(goal);
                _refreshGoals();
                Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create goal: $e'),
                    backgroundColor: Colors.red[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSavedDialog(Goal goal) {
    final savedController =
        TextEditingController(text: goal.savedAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Update Saved Amount - ${goal.title}'),
        content: TextField(
          controller: savedController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Saved Amount',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final updatedGoal = goal.copyWith(
                savedAmount: double.tryParse(savedController.text.trim()) ??
                    goal.savedAmount,
              );
              await _apiService.updateGoal(updatedGoal);
              _refreshGoals();
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final percent = goal.savedAmount / goal.targetAmount;
    final left = goal.targetAmount - goal.savedAmount;

    return Card(
      elevation: 4,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.flag, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    color: Colors.lightBlueAccent,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Saved \$${goal.savedAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)} (${(percent * 100).toStringAsFixed(0)}%)",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Left \$${left.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showEditSavedDialog(goal),
                      ),
                      IconButton(
                        icon: Icon(
                          goal.isAchieved
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          await _apiService.toggleGoalAchieved(goal);
                          _refreshGoals();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _apiService.deleteGoal(goal.id);
                          _refreshGoals();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Goals"),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Goal>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No goals found.'));
          }

          final goals = snapshot.data!;
          final activeGoals = goals.where((g) => !g.isAchieved).toList();
          final achievedGoals = goals.where((g) => g.isAchieved).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activeGoals.isNotEmpty) ...[
                  const Text(
                    "Active Goals",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...activeGoals.map((goal) => _buildGoalCard(goal)).toList(),
                ],
                if (achievedGoals.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    "Achieved Goals",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...achievedGoals.map((goal) => _buildGoalCard(goal)).toList(),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
