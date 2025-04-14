import 'package:flutter_test/flutter_test.dart';
import 'package:interview_task_rapid/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Task Model Tests', () {
    final testTask = Task(
      id: 'test-id',
      title: 'Test Task',
      description: 'Test Description',
      isCompleted: false,
      ownerId: 'owner-id',
      ownerEmail: 'owner@test.com',
      sharedWith: ['shared@test.com'],
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    test('Task creation with all parameters', () {
      expect(testTask.id, 'test-id');
      expect(testTask.title, 'Test Task');
      expect(testTask.description, 'Test Description');
      expect(testTask.isCompleted, false);
      expect(testTask.ownerId, 'owner-id');
      expect(testTask.ownerEmail, 'owner@test.com');
      expect(testTask.sharedWith, ['shared@test.com']);
    });

    test('Task copyWith method', () {
      final updatedTask = testTask.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(updatedTask.id, testTask.id);
      expect(updatedTask.title, 'Updated Title');
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.description, testTask.description);
    });

    test('Task toFirestore conversion', () {
      final firestoreData = testTask.toFirestore();
      
      expect(firestoreData['id'], testTask.id);
      expect(firestoreData['title'], testTask.title);
      expect(firestoreData['description'], testTask.description);
      expect(firestoreData['isCompleted'], testTask.isCompleted);
      expect(firestoreData['ownerId'], testTask.ownerId);
      expect(firestoreData['ownerEmail'], testTask.ownerEmail);
      expect(firestoreData['sharedWith'], testTask.sharedWith);
    });

    test('Task fromFirestore factory', () {
      final data = {
        'title': 'Test Task',
        'description': 'Test Description',
        'isCompleted': false,
        'ownerId': 'owner-id',
        'ownerEmail': 'owner@test.com',
        'sharedWith': ['shared@test.com'],
        'createdAt': Timestamp.fromDate(DateTime(2024)),
        'updatedAt': Timestamp.fromDate(DateTime(2024)),
      };

      final task = Task(
        id: 'test-id',
        title: data['title'] as String,
        description: data['description'] as String,
        isCompleted: data['isCompleted'] as bool,
        ownerId: data['ownerId'] as String,
        ownerEmail: data['ownerEmail'] as String,
        sharedWith: List<String>.from(data['sharedWith'] as List),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );

      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, false);
      expect(task.ownerId, 'owner-id');
      expect(task.ownerEmail, 'owner@test.com');
      expect(task.sharedWith, ['shared@test.com']);
    });
  });
} 