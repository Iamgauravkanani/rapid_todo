import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_task_rapid/core/constants/app_constants.dart';
import 'package:interview_task_rapid/models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = AppConstants.tasksCollection;

  // Create a new task
  Future<Task> createTask(Task task) async {
    final docRef = await _firestore.collection(_collection).add(task.toFirestore());
    return task.copyWith(id: docRef.id);
  }

  // Get all tasks for a user (both owned and shared)
  Stream<List<Task>> getUserTasks(String userId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Get shared tasks
  Stream<List<Task>> getSharedTasks(String userEmail) {
    return _firestore
        .collection(_collection)
        .where('sharedWith', arrayContains: userEmail)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Update a task
  Future<void> updateTask(Task task) async {
    await _firestore.collection(_collection).doc(task.id).update(task.toFirestore());
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collection).doc(taskId).delete();
  }

  // Share a task with another user
  Future<void> shareTask(String taskId, String userEmail) async {
    await _firestore.collection(_collection).doc(taskId).update({
      'sharedWith': FieldValue.arrayUnion([userEmail]),
    });
  }

  // Remove sharing from a task
  Future<void> unshareTask(String taskId, String userEmail) async {
    await _firestore.collection(_collection).doc(taskId).update({
      'sharedWith': FieldValue.arrayRemove([userEmail]),
    });
  }
} 