import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, completed }

extension TaskStatusX on TaskStatus {
  String get value => name; // 'pending' | 'completed'

  static TaskStatus fromString(String raw) {
    return TaskStatus.values.firstWhere(
      (s) => s.value == raw,
      orElse: () => TaskStatus.pending,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime dueDate;
  final TaskStatus status;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    required this.status,
  });

  bool get isCompleted => status == TaskStatus.completed;

  /// Builds a Task from a Firestore document snapshot.
  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: TaskStatusX.fromString(data['status'] as String? ?? 'pending'),
    );
  }

  /// Converts to a map for Firestore writes. createdAt is intentionally
  /// omitted here for updates — see TaskRepository.updateTask, which never
  /// overwrites the original creation timestamp.
  Map<String, dynamic> toFirestoreCreate() {
    return {
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status.value,
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status.value,
    };
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}