import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:interview_task_rapid/core/widgets/responsive_layout.dart';
import 'package:interview_task_rapid/models/task.dart';
import 'package:interview_task_rapid/view_models/task_view_model.dart';
import 'package:interview_task_rapid/widgets/shared_task_tile.dart';
import 'package:interview_task_rapid/widgets/task_tile.dart';
import 'package:provider/provider.dart';

class SharedTasksScreen extends StatelessWidget {
  const SharedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: context.watch<TaskViewModel>().sharedTasks,
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
          return const Center(
            child: Text('No shared tasks yet'),
          );
        }

        return ResponsiveLayout(
          mobile: _buildListView(tasks),
          tablet: _buildGridView(tasks, crossAxisCount: 2),
          desktop: _buildGridView(tasks, crossAxisCount: 3),
        );
      },
    );
  }

  Widget _buildListView(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return SharedTaskTile(
          task: task,
          onToggleComplete: () => context.read<TaskViewModel>().toggleTask(task),
        );
      },
    );
  }

  Widget _buildGridView(List<Task> tasks, {required int crossAxisCount}) {
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
          child: SharedTaskTile(
            task: task,
            onToggleComplete: () => context.read<TaskViewModel>().toggleTask(task),
          ),
        );
      },
    );
  }
} 