import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/task_model.dart';

/// Bundles what the stream needs to expose beyond just the task list:
/// - isFromCache: true when this snapshot came from local cache rather
///   than a confirmed server response — our offline-indicator signal.
/// - hasMore: heuristic for pagination — if we got exactly `limit` docs,
///   there is likely at least one more page.
class TaskSnapshot {
  final List<Task> tasks;
  final bool isFromCache;
  final bool hasMore;

  TaskSnapshot({
    required this.tasks,
    required this.isFromCache,
    required this.hasMore,
  });
}

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

  /// Real-time, paginated stream of the user's tasks, newest due date first.
  ///
  /// Pagination approach: rather than cursor-based pagination (which would
  /// require dropping the live listener), we simply grow `limit` when the
  /// user asks for more ("Load more" / reaching the end of the list) and
  /// re-subscribe. This keeps every currently-loaded task live-updating,
  /// which matters far more for a personal task list than true infinite
  /// pagination — most users will only ever have a handful of pages.
  ///
  /// includeMetadataChanges: true lets us detect `isFromCache`, which is
  /// how we surface the offline indicator without adding a connectivity
  /// package — Firestore already tells us this for free.
  Stream<TaskSnapshot> streamTasks({required int limit}) {
    return _tasksRef
        .orderBy('dueDate')
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      final tasks = snapshot.docs.map(Task.fromFirestore).toList();
      return TaskSnapshot(
        tasks: tasks,
        isFromCache: snapshot.metadata.isFromCache,
        hasMore: tasks.length >= limit,
      );
    });
  }

  /// One-off fetch for the explicit pull-to-refresh gesture, respecting
  /// the currently loaded page size so refresh doesn't silently shrink
  /// or grow the list the user is looking at.
  Future<List<Task>> fetchTasksOnce({required int limit}) async {
    try {
      final snapshot = await _tasksRef.orderBy('dueDate').limit(limit).get();
      return snapshot.docs.map(Task.fromFirestore).toList();
    } catch (_) {
      throw AppException('Could not refresh tasks. Check your connection.');
    }
  }

  Future<String> addTask(Task task) async {
    try {
      final docRef = await _tasksRef.add(task.toFirestoreCreate());
      return docRef.id;
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