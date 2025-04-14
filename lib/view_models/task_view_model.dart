import 'package:flutter/material.dart';
import 'package:interview_task_rapid/models/task.dart';
import 'package:interview_task_rapid/services/task_service.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService;
  final String userId;
  final String userEmail;

  TaskViewModel({
    required TaskService taskService,
    required this.userId,
    required this.userEmail,
  }) : _taskService = taskService {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // no icon needed for now
      [
        NotificationChannel(
          channelKey: 'task_reminders',
          channelName: 'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
        ),
      ],
    );
  }

  Stream<List<Task>> get userTasks => _taskService.getUserTasks(userId);
  Stream<List<Task>> get sharedTasks => _taskService.getSharedTasks(userEmail);

  Future<void> createTask({
    required String title,
    required String description,
    DateTime? dueDate,
    bool hasReminder = false,
  }) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      isCompleted: false,
      ownerId: userId,
      ownerEmail: userEmail,
      sharedWith: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      hasReminder: hasReminder,
    );

    await _taskService.createTask(task);
    if (hasReminder && dueDate != null) {
      await _scheduleReminder(task);
    }
  }

  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _taskService.updateTask(updatedTask);
    if (updatedTask.hasReminder && updatedTask.dueDate != null) {
      await _scheduleReminder(updatedTask);
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    await AwesomeNotifications().cancel(taskId.hashCode);
  }

  Future<void> shareTask(String taskId, String email) async {
    try {
      await _taskService.shareTask(taskId, email);
    } catch (e) {
      debugPrint('Error sharing task: $e');
      rethrow;
    }
  }

  Future<void> unshareTask(String taskId, String email) async {
    await _taskService.unshareTask(taskId, email);
  }

  Future<void> toggleTask(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _taskService.updateTask(updatedTask);
  }

  Future<void> _scheduleReminder(Task task) async {
    if (task.dueDate == null) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: task.id.hashCode,
        channelKey: 'task_reminders',
        title: 'Task Reminder: ${task.title}',
        body: 'This task is due soon!',
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar.fromDate(
        date: task.dueDate!,
      ),
    );
  }
} 