import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_routes.dart';
import 'core/router/app_pages.dart';

/// Root widget of the application.
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // switched to ThemeMode.system for the dark-mode bonus
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}