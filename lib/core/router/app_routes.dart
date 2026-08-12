/// Central place for all route name strings.
/// Never hardcode a route string anywhere else in the app —
/// always reference AppRoutes.xxx so a typo becomes a compile error, not a runtime bug.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String taskForm = '/task-form';
  static const String taskDetails = '/task-details';
}