import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_task_rapid/models/task.dart';
import 'package:interview_task_rapid/widgets/task_tile.dart';

void main() {
  late Task task;
  late bool isEditCalled;
  late bool isDeleteCalled;
  late bool isShareCalled;
  late bool isToggleCompleteCalled;

  setUp(() {
    task = Task(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      isCompleted: false,
      ownerId: 'owner-id',
      ownerEmail: 'owner@example.com',
      sharedWith: ['user1@example.com', 'user2@example.com'],
      createdAt: DateTime(2024, 4, 12),
      updatedAt: DateTime(2024, 4, 12),
      dueDate: DateTime(2024, 4, 12),
      hasReminder: true,
    );

    isEditCalled = false;
    isDeleteCalled = false;
    isShareCalled = false;
    isToggleCompleteCalled = false;
  });

  Widget createTaskTile() {
    return MaterialApp(
      home: Scaffold(
        body: TaskTile(
          task: task,
          onEdit: () => isEditCalled = true,
          onDelete: () => isDeleteCalled = true,
          onShare: () => isShareCalled = true,
          onToggleComplete: () => isToggleCompleteCalled = true,
        ),
      ),
    );
  }

  group('TaskTile Widget Tests', () {
    testWidgets('renders task title and description correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('displays due date when provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.text('Apr 12, 2024'), findsOneWidget);
    });

    testWidgets('shows reminder icon when hasReminder is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('Reminder set'), findsOneWidget);
    });

    testWidgets('displays shared users count', (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.text('Shared with 2 users'), findsOneWidget);
    });

    testWidgets('shows owner email indicator', (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('calls onToggleComplete when checkbox is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(isToggleCompleteCalled, isTrue);
    });

    testWidgets('calls onEdit when edit button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      await tester.drag(find.byType(TaskTile), const Offset(300, 0));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(isEditCalled, isTrue);
    });

    testWidgets('calls onShare when share button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      await tester.drag(find.byType(TaskTile), const Offset(300, 0));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      expect(isShareCalled, isTrue);
    });

    testWidgets('calls onDelete when delete button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTaskTile());

      await tester.drag(find.byType(TaskTile), const Offset(300, 0));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(isDeleteCalled, isTrue);
    });

    testWidgets('applies strikethrough style when task is completed',
        (WidgetTester tester) async {
      task = task.copyWith(isCompleted: true);
      await tester.pumpWidget(createTaskTile());

      final titleFinder = find.text('Test Task');
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.decoration, TextDecoration.lineThrough);
    });
  });
} 