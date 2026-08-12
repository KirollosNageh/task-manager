import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/router/app_routes.dart';

/// Placeholder — will be replaced with the real task list UI
/// (StreamBuilder + loading/empty/error states) once TaskController
/// and TaskRepository exist.
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.offAllNamed(AppRoutes.login),
          ),
        ],
      ),
      body: const Center(child: Text('Task list will render here')),
    );
  }
}