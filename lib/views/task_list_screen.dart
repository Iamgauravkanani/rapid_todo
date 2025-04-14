import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_task_rapid/core/widgets/responsive_layout.dart';
import 'package:interview_task_rapid/models/task.dart';
import 'package:interview_task_rapid/view_models/task_view_model.dart';
import 'package:interview_task_rapid/widgets/task_tile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
     
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: context.watch<TaskViewModel>().userTasks,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                final tasks = snapshot.data!;

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Tasks Yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first task by tapping the + button',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ResponsiveLayout(
                  mobile: _buildListView(tasks, context),
                  tablet: _buildGridView(tasks, context, crossAxisCount: 2),
                  desktop: _buildGridView(tasks, context, crossAxisCount: 3),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Task> tasks, BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onEdit: () => _showTaskDialog(context, task: task),
          onDelete: () => _deleteTask(context, task),
          onShare: () => _shareTask(context, task),
          onToggleComplete: () => context.read<TaskViewModel>().toggleTask(task),
        );
      },
    );
  }

  Widget _buildGridView(List<Task> tasks, BuildContext context, {required int crossAxisCount}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: TaskTile(
            task: task,
            onEdit: () => _showTaskDialog(context, task: task),
            onDelete: () => _deleteTask(context, task),
            onShare: () => _shareTask(context, task),
            onToggleComplete: () => context.read<TaskViewModel>().toggleTask(task),
          ),
        );
      },
    );
  }

  Future<void> _showTaskDialog(BuildContext context, {Task? task}) async {
    final titleController = TextEditingController(text: task?.title);
    final descriptionController = TextEditingController(text: task?.description);
    DateTime? selectedDate = task?.dueDate;
    bool hasReminder = task?.hasReminder ?? false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(task == null ? 'Create Task' : 'Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(selectedDate?.toString() ?? 'No due date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                      );
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Set Reminder'),
                  value: hasReminder,
                  onChanged: (value) {
                    setState(() {
                      hasReminder = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final viewModel = context.read<TaskViewModel>();
                if (task == null) {
                  viewModel.createTask(
                    title: titleController.text,
                    description: descriptionController.text,
                    dueDate: selectedDate,
                    hasReminder: hasReminder,
                  );
                } else {
                  viewModel.updateTask(
                    task.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      dueDate: selectedDate,
                      hasReminder: hasReminder,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(task == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<TaskViewModel>().deleteTask(task.id);
    }
  }

  Future<void> _shareTask(BuildContext context, Task task) async {
    try {
      final emailController = TextEditingController();
      final email = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share Task via Email'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter email address',
              hintText: 'user@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, emailController.text),
              child: const Text('Share'),
            ),
          ],
        ),
      );

      if (email != null && email.isNotEmpty) {
        // Validate email format
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a valid email address')),
            );
          }
          return;
        }

        final String subject = 'Task: ${task.title}';
        final String body = '''
Task Details:

Title: ${task.title}
Description: ${task.description}
Status: ${task.isCompleted ? 'Completed' : 'Pending'}
Due Date: ${task.dueDate != null ? task.dueDate!.toString().split(' ')[0] : 'Not set'}

---
This task was shared via Task Manager App.
''';

        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: email,
          queryParameters: {
            'subject': subject,
            'body': body,
          },
        );

        try {
          if (await canLaunchUrl(emailUri)) {
            await launchUrl(emailUri);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email opened for $email'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            throw Exception('Could not launch email client');
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open email client: ${e.toString()}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share task: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
} 