import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

/// The four UI states a data screen can be in. Kept as an enum (instead of
/// separate booleans) so the UI can never represent an invalid combination
/// like "loading AND error" at the same time.
enum TaskViewState { loading, empty, loaded, error }

/// null = no status filter applied (show both pending and completed).
typedef StatusFilter = TaskStatus?;

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();

  /// How many tasks to load per "page". Kept small on purpose so the
  /// Load More / pagination behavior is easy to see and demo.
  static const int _pageSize = 10;

  /// Raw, unfiltered data for the currently loaded page(s).
  final tasks = <Task>[].obs;
  final viewState = TaskViewState.loading.obs;
  final errorMessage = RxnString();
  final isRefreshing = false.obs;

  // --- Pagination (bonus) ---
  final _currentLimit = _pageSize.obs;
  final isLoadingMore = false.obs;
  final hasMore = false.obs;

  // --- Offline indicator (bonus) ---
  // True when the most recent snapshot came from local cache rather than
  // a confirmed server response — Firestore's own signal, no extra
  // connectivity package needed.
  final isOffline = false.obs;

  // --- Search & Filter (bonus) ---
  // NOTE: search/filter apply only to the tasks currently loaded on-page,
  // not the user's entire task history — a deliberate trade-off documented
  // in the README so it's not a hidden limitation.
  final searchQuery = ''.obs;
  final statusFilter = Rx<StatusFilter>(null);

  StreamSubscription<TaskSnapshot>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscribe(showFullLoading: true);
  }

  void _subscribe({required bool showFullLoading}) {
    if (showFullLoading) viewState.value = TaskViewState.loading;
    _subscription?.cancel();
    _subscription = _repository.streamTasks(limit: _currentLimit.value).listen(
      (snapshot) {
        tasks.value = snapshot.tasks;
        isOffline.value = snapshot.isFromCache;
        hasMore.value = snapshot.hasMore;
        isLoadingMore.value = false;
        viewState.value =
            snapshot.tasks.isEmpty ? TaskViewState.empty : TaskViewState.loaded;
      },
      onError: (_) {
        isLoadingMore.value = false;
        errorMessage.value = 'Could not load tasks. Check your connection.';
        viewState.value = TaskViewState.error;
      },
    );
  }

  /// Grows the page size and re-subscribes. The live listener means every
  /// task on every already-loaded page keeps updating in real time — we're
  /// only ever widening the window, never losing live updates.
  void loadMore() {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _currentLimit.value += _pageSize;
    _subscribe(showFullLoading: false); // no full-screen spinner for "load more"
  }

  /// Applies the current search query + status filter on top of the
  /// currently loaded page(s). Local filtering only — instant, no network.
  List<Task> get filteredTasks {
    var result = tasks.toList();

    final filter = statusFilter.value;
    if (filter != null) {
      result = result.where((t) => t.status == filter).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              t.description.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  void setStatusFilter(StatusFilter filter) => statusFilter.value = filter;

  void clearFilters() {
    searchQuery.value = '';
    statusFilter.value = null;
  }

  /// Bound to RefreshIndicator's onRefresh. The live stream above already
  /// keeps `tasks` up to date automatically, but pull-to-refresh should
  /// still perform a visible, user-triggered fetch and surface any error.
  Future<void> pullToRefresh() async {
    isRefreshing.value = true;
    try {
      final data = await _repository.fetchTasksOnce(limit: _currentLimit.value);
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