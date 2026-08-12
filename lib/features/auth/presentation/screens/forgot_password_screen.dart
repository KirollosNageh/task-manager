import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailSent = false.obs;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _authController.clearError();
    if (_formKey.currentState!.validate()) {
      final success = await _authController.sendPasswordReset(_emailController.text);
      if (success) _emailSent.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Obx(() {
            if (_emailSent.value) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read_outlined,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Check your email',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'We sent a password reset link to ${_emailController.text}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(label: 'Back to Login', onPressed: () => Get.back()),
                ],
              );
            }

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Forgot your password?',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Enter your email and we'll send you a reset link",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_authController.errorMessage.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        _authController.errorMessage.value!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  AppButton(
                    label: 'Send Reset Link',
                    isLoading: _authController.isLoading.value,
                    onPressed: _submit,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}