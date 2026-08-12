import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/router/app_routes.dart';

/// Placeholder — will be replaced with the real login UI + form in Step 6.
/// Kept intentionally minimal here so we can verify routing works end-to-end
/// before adding Firebase Auth logic.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login (placeholder)')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.offAllNamed(AppRoutes.home),
          child: const Text('Simulate Login → Go Home'),
        ),
      ),
    );
  }
}