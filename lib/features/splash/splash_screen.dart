import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/presentation/controllers/auth_controller.dart';

/// Shown briefly on app start. AuthController's onInit() binds to
/// FirebaseAuth's authStateChanges() stream and redirects automatically
/// (see AuthController._handleAuthChange) — this screen just needs to
/// exist as the initial route so there's something to redirect FROM.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensures AuthController exists (and its stream binds) as soon as the
    // app starts, even before the login screen's own binding would run.
    Get.put(AuthController(), permanent: true);

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