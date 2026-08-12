import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';

/// Maps every AppRoutes.xxx name to its screen (and later, its Binding).
/// This is the ONLY file that should ever construct a screen for navigation —
/// screens navigate via Get.toNamed(AppRoutes.xxx), never by importing
/// each other's screen classes directly.
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
      // binding: AuthBinding(), // added in Step 6
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const TaskListScreen(),
      // binding: TaskBinding(), // added in the task-management step
    ),
    // register, forgotPassword, taskForm, taskDetails added as their
    // screens are built in later steps.
  ];
}