import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/repositories/auth_repository.dart';

/// Holds ALL auth-related business logic and state. Screens read from
/// this controller's reactive fields (.obs) via Obx() and call its methods
/// on button presses — screens themselves contain zero Firebase logic.
class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final NotificationService _notificationService = NotificationService();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  final Rxn<User> _authUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Single source of truth for "is the user logged in". Fires immediately
    // with the current session on app start (persistent login), and again
    // on every future login/logout — this is what makes "keep user logged in"
    // and automatic redirect-on-logout work with zero extra code anywhere else.
    _authUser.bindStream(_repository.authStateChanges);
    ever(_authUser, _handleAuthChange);
  }

  void _handleAuthChange(User? user) {
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.home);
      // FCM only makes sense once we know which user to attach the token
      // to, so it's initialized here rather than at raw app startup.
      _notificationService.init();
    }
  }

  Future<void> register({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repository.registerWithEmail(email: email, password: password);
      // Navigation happens automatically via the authStateChanges listener above.
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repository.loginWithEmail(email: email, password: password);
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    // Navigation to login happens automatically via the listener too.
  }

  void clearError() => errorMessage.value = null;
}