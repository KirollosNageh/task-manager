import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_routes.dart';
import 'core/router/app_pages.dart';
import 'core/controllers/settings_controller.dart';

/// Root widget of the application.
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.put(SettingsController(), permanent: true);

    return Obx(() => GetMaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode.value,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
          // A single line gives every screen transition a consistent,
          // polished feel instead of the platform's abrupt default.
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 250),
        ));
  }
}