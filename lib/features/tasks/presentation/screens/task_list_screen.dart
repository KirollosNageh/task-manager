import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/controllers/settings_controller.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/task_model.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_card.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/app_alert_dialog.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, AuthController authController) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AppAlertDialog(
            icon: Icons.logout_rounded,
            title: 'Logout?',
            message: 'Are you sure you want to logout?',
            cancelText: 'Cancel',
            confirmText: 'Logout',
            onCancel: () => Navigator.pop(ctx, false),
            onConfirm: () => Navigator.pop(ctx, true),
          ),
        ) ??
        false;

    if (confirmed) {
      await authController.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(settingsController.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
                tooltip: 'Toggle dark mode',
                onPressed: settingsController.toggleDarkMode,
              )),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context, authController),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Get.toNamed(AppRoutes.taskForm),
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: SizedBox(
  width: 60,
  height: 60,
  child: FloatingActionButton(
    onPressed: () => Get.toNamed(AppRoutes.taskForm),
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(
      Icons.add,
      size: 24,
    ),
  ),
),
      body: Column(
        children: [
          // Offline indicator — only takes space when actually offline,
          // so it never affects layout for the common (online) case.
          Obx(() => taskController.isOffline.value
              ? const OfflineBanner()
              : const SizedBox.shrink()),
          _SearchAndFilterBar(controller: taskController),
          Expanded(
            child: Obx(() {
              switch (taskController.viewState.value) {
                case TaskViewState.loading:
                  return const LoadingWidget(message: 'Loading your tasks...');

                case TaskViewState.error:
                  return ErrorStateWidget(
                    message: taskController.errorMessage.value ??
                        'Something went wrong.',
                    onRetry: taskController.pullToRefresh,
                  );

                case TaskViewState.empty:
                  return RefreshIndicator(
                    onRefresh: taskController.pullToRefresh,
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: const EmptyStateWidget(
                            icon: Icons.task_alt_outlined,
                            title: 'No tasks yet',
                            subtitle:
                                'Tap the + button to add your first task.',
                          ),
                        ),
                      ],
                    ),
                  );

                case TaskViewState.loaded:
                  final tasks = taskController.filteredTasks;

                  if (tasks.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: taskController.pullToRefresh,
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: EmptyStateWidget(
                              icon: Icons.search_off,
                              title: 'No matching tasks',
                              subtitle:
                                  'Try a different search term or filter.',
                              action: TextButton(
                                onPressed: taskController.clearFilters,
                                child: const Text('Clear filters'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: taskController.pullToRefresh,
                    child: NotificationListener<ScrollNotification>(
                      // Auto-load the next page when the user nears the
                      // bottom of the list — the simplified pagination
                      // trigger, alongside the explicit "Load more" button.
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200) {
                          taskController.loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        // +1 slot for the "load more" footer, shown only
                        // when there might be more tasks to fetch.
                        itemCount: tasks.length + 1,
                        itemBuilder: (context, index) {
                          if (index == tasks.length) {
                            return Obx(() {
                              if (!taskController.hasMore.value) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                child: Center(
                                  child: taskController.isLoadingMore.value
                                      ? const CircularProgressIndicator()
                                      : TextButton(
                                          onPressed: taskController.loadMore,
                                          child: const Text('Load more'),
                                        ),
                                ),
                              );
                            });
                          }

                          final task = tasks[index];
                          return FadeSlideIn(
                            index: index,
                            child: TaskCard(
                              task: task,
                              onTap: () => Get.toNamed(AppRoutes.taskForm,
                                  arguments: task),
                              onToggleStatus: () =>
                                  taskController.toggleStatus(task),
                              onDelete: () =>
                                  taskController.deleteTask(task.id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
              }
            }),
          ),
        ],
      ),
    );
  }
}

/// Search field + status filter chips, shown above the task list.
class _SearchAndFilterBar extends StatelessWidget {
  final TaskController controller;
  const _SearchAndFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: const InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: controller.statusFilter.value == null,
                      onSelected: () => controller.setStatusFilter(null),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _FilterChip(
                      label: 'Pending',
                      selected:
                          controller.statusFilter.value == TaskStatus.pending,
                      onSelected: () =>
                          controller.setStatusFilter(TaskStatus.pending),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _FilterChip(
                      label: 'Completed',
                      selected: controller.statusFilter.value ==
                          TaskStatus.completed,
                      onSelected: () =>
                          controller.setStatusFilter(TaskStatus.completed),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}