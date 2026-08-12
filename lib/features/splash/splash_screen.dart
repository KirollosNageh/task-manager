import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/router/app_routes.dart';

/// Shown briefly on app start while we determine whether the user
/// is already logged in. In this step it uses a mock 1-second delay
/// and always routes to login; Step 6 will replace the mock check
/// with FirebaseAuth.instance.authStateChanges().
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    // TODO(step-6): replace with real FirebaseAuth check, e.g.:
    // final user = FirebaseAuth.instance.currentUser;
    // Get.offAllNamed(user != null ? AppRoutes.home : AppRoutes.login);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64),
            SizedBox(height: 16),
            Text('Task Manager'),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}