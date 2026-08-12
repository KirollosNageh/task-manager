import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/task_model.dart';

/// The ONLY class that talks to the `users/{uid}/tasks` subcollection.
/// Every method scopes automatically to the currently signed-in user via
/// _userId, so there is no way for a call from this repository to
/// accidentally read or write another user's tasks.
class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw AppException('You must be logged in to manage tasks.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  /// Real-time stream of the user's tasks, newest due date first.
  /// Used by TaskController to keep the list live-updated across devices.
  Stream<List<Task>> streamTasks() {
    return _tasksRef.orderBy('dueDate').snapshots().map(
          (snapshot) => snapshot.docs.map(Task.fromFirestore).toList(),
        );
  }

  /// One-off fetch, used for the explicit pull-to-refresh gesture.
  /// The stream above already keeps data live, but a pull-to-refresh
  /// action should still trigger a visible, user-initiated re-fetch.
  Future<List<Task>> fetchTasksOnce() async {
    try {
      final snapshot = await _tasksRef.orderBy('dueDate').get();
      return snapshot.docs.map(Task.fromFirestore).toList();
    } catch (_) {
      throw AppException('Could not refresh tasks. Check your connection.');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _tasksRef.add(task.toFirestoreCreate());
    } catch (_) {
      throw AppException('Could not add task. Please try again.');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _tasksRef.doc(task.id).update(task.toFirestoreUpdate());
    } catch (_) {
      throw AppException('Could not update task. Please try again.');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksRef.doc(taskId).delete();
    } catch (_) {
      throw AppException('Could not delete task. Please try again.');
    }
  }

  Future<void> setStatus(String taskId, TaskStatus status) async {
    try {
      await _tasksRef.doc(taskId).update({'status': status.value});
    } catch (_) {
      throw AppException('Could not update task status. Please try again.');
    }
  }
}