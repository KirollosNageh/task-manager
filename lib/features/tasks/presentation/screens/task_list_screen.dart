import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_card.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: authController.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.taskForm),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
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
              // Wrapped in a scrollable so pull-to-refresh works even
              // when the empty state doesn't fill/overflow the screen.
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: EmptyStateWidget(
                      icon: Icons.task_alt_outlined,
                      title: 'No tasks yet',
                      subtitle: 'Tap the + button to add your first task.',
                    ),
                  ),
                ],
              ),
            );

          case TaskViewState.loaded:
            final tasks = taskController.tasks;
            return RefreshIndicator(
              onRefresh: taskController.pullToRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () => Get.toNamed(AppRoutes.taskForm, arguments: task),
                    onToggleStatus: () => taskController.toggleStatus(task),
                    onDelete: () => taskController.deleteTask(task.id),
                  );
                },
              ),
            );
        }
      }),
    );
  }
}