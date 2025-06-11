import 'package:cs_3541_final_project/presenters/career_goals_presenter.dart';
import 'package:cs_3541_final_project/views/common_app_bar.dart';
import 'package:flutter/material.dart';

class CareerGoalsViewPage extends StatefulWidget {
  const CareerGoalsViewPage({super.key});

  @override
  State<CareerGoalsViewPage> createState() => _CareerGoalsViewPageState();
}

class _CareerGoalsViewPageState extends State<CareerGoalsViewPage> {
  final CareerGoalsPresenter _presenter = CareerGoalsPresenter();

  @override
  Widget build(BuildContext context) {
    final careerGoals = _presenter.getCareerGoals();

    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Career Goals',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Career Goals',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: careerGoals.isEmpty
                  ? const Center(
                      child: Text(
                        'No career goals added yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: careerGoals.length,
                      itemBuilder: (context, index) {
                        final goal = careerGoals[index];
                        return ListTile(
                          leading: Checkbox(
                            value: goal.completed,
                            onChanged: (bool? value) {
                              setState(() {
                                _presenter.toggleGoalCompletion(index);
                              });
                            },
                          ),
                          title: Text(
                            goal.text,
                            style: TextStyle(
                              decoration: goal.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(goal.type),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGoalDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final TextEditingController goalController = TextEditingController();
    String goalType = 'Short Term';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Career Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: goalController,
                decoration:
                    const InputDecoration(hintText: 'Enter your career goal'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: goalType,
                items: const [
                  DropdownMenuItem(
                      value: 'Short Term', child: Text('Short Term')),
                  DropdownMenuItem(
                      value: 'Long Term', child: Text('Long Term')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    goalType = newValue;
                  }
                },
                decoration: const InputDecoration(labelText: 'Goal Type'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (goalController.text.isNotEmpty) {
                  setState(() {
                    _presenter.addCareerGoal(goalController.text, goalType);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
