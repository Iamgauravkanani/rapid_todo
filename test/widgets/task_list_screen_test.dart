import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_task_rapid/models/task.dart';
import 'package:interview_task_rapid/services/task_service.dart';
import 'package:interview_task_rapid/view_models/task_view_model.dart';
import 'package:interview_task_rapid/views/task_list_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'task_list_screen_test.mocks.dart';

@GenerateMocks([TaskService, TaskViewModel])
void main() {
  group('TaskListScreen Widget Tests', () {
    late MockTaskService mockTaskService;
    late MockTaskViewModel mockTaskViewModel;

    setUp(() {
      mockTaskService = MockTaskService();
      mockTaskViewModel = MockTaskViewModel();
    });

    testWidgets('displays empty state when no tasks', (WidgetTester tester) async {
      when(mockTaskViewModel.userTasks).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskViewModel>.value(
            value: mockTaskViewModel,
            child: const TaskListScreen(),
          ),
        ),
      );

      expect(find.text('No tasks yet'), findsOneWidget);
    });

    testWidgets('displays list of tasks', (WidgetTester tester) async {
      final tasks = [
        Task(
          id: '1',
          title: 'Task 1',
          description: 'Description 1',
          isCompleted: false,
          ownerId: 'user1',
          ownerEmail: 'user1@test.com',
          sharedWith: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Task 2',
          description: 'Description 2',
          isCompleted: true,
          ownerId: 'user1',
          ownerEmail: 'user1@test.com',
          sharedWith: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockTaskViewModel.userTasks).thenAnswer((_) => Stream.value(tasks));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskViewModel>.value(
            value: mockTaskViewModel,
            child: const TaskListScreen(),
          ),
        ),
      );

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('can toggle task completion', (WidgetTester tester) async {
      final task = Task(
        id: '1',
        title: 'Task 1',
        description: 'Description 1',
        isCompleted: false,
        ownerId: 'user1',
        ownerEmail: 'user1@test.com',
        sharedWith: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockTaskViewModel.userTasks).thenAnswer((_) => Stream.value([task]));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskViewModel>.value(
            value: mockTaskViewModel,
            child: const TaskListScreen(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pumpAndSettle();

      verify(mockTaskViewModel.toggleTask(task)).called(1);
    });

    testWidgets('can delete task', (WidgetTester tester) async {
      final task = Task(
        id: '1',
        title: 'Task 1',
        description: 'Description 1',
        isCompleted: false,
        ownerId: 'user1',
        ownerEmail: 'user1@test.com',
        sharedWith: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockTaskViewModel.userTasks).thenAnswer((_) => Stream.value([task]));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskViewModel>.value(
            value: mockTaskViewModel,
            child: const TaskListScreen(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      verify(mockTaskViewModel.deleteTask(task.id)).called(1);
    });
  });
} 