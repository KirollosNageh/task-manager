import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';

/// Root widget of the application.
/// Routes will be registered here once we build the router in a later step
/// (getPages: AppPages.routes).
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // will switch to ThemeMode.system for the dark-mode bonus
      // getPages: AppPages.routes, // wired in the routing step
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary placeholder so the app is runnable and visually verifiable
/// before routing/auth screens exist. Will be removed once real screens
/// (Splash -> Auth check) are wired in.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Task Manager', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Theme wired successfully ✅'),
          ],
        ),
      ),
    );
  }
}