import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/tasks/presentation/bindings/task_binding.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';

/// Maps every AppRoutes.xxx name to its screen and Binding.
class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const TaskListScreen(),
      binding: TaskBinding(),
    ),
    // TODO(step-8): replace with the real TaskFormScreen (add/edit).
    GetPage(
      name: AppRoutes.taskForm,
      page: () => const Scaffold(
        body: Center(child: Text('Task form coming in the next step')),
      ),
      binding: TaskBinding(),
    ),
  ];
}