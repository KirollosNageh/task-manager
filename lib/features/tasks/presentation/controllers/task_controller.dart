import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

/// The four UI states a data screen can be in. Kept as an enum (instead of
/// separate booleans) so the UI can never represent an invalid combination
/// like "loading AND error" at the same time.
enum TaskViewState { loading, empty, loaded, error }

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();

  final tasks = <Task>[].obs;
  final viewState = TaskViewState.loading.obs;
  final errorMessage = RxnString();
  final isRefreshing = false.obs;

  StreamSubscription<List<Task>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToTasks();
  }

  void _listenToTasks() {
    viewState.value = TaskViewState.loading;
    _subscription?.cancel();
    _subscription = _repository.streamTasks().listen(
      (data) {
        tasks.value = data;
        viewState.value = data.isEmpty ? TaskViewState.empty : TaskViewState.loaded;
      },
      onError: (_) {
        errorMessage.value = 'Could not load tasks. Check your connection.';
        viewState.value = TaskViewState.error;
      },
    );
  }

  /// Bound to RefreshIndicator's onRefresh. The live stream above already
  /// keeps `tasks` up to date automatically, but pull-to-refresh should
  /// still perform a visible, user-triggered fetch and surface any error.
  Future<void> pullToRefresh() async {
    isRefreshing.value = true;
    try {
      final data = await _repository.fetchTasksOnce();
      tasks.value = data;
      viewState.value = data.isEmpty ? TaskViewState.empty : TaskViewState.loaded;
    } on AppException catch (e) {
      Get.snackbar('Refresh failed', e.message);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<bool> addTask(Task task) => _mutate(() => _repository.addTask(task));

  Future<bool> updateTask(Task task) => _mutate(() => _repository.updateTask(task));

  Future<bool> deleteTask(String taskId) => _mutate(() => _repository.deleteTask(taskId));

  Future<bool> toggleStatus(Task task) {
    final newStatus =
        task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    return _mutate(() => _repository.setStatus(task.id, newStatus));
  }

  /// Wraps every write operation with consistent error surfacing so screens
  /// don't need their own try/catch around each call.
  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
      return false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}