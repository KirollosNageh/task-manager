import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Registers AuthController before any auth-related screen builds.
/// fenix: true means GetX recreates the controller if it was previously
/// disposed (e.g. after logout -> login again), instead of crashing.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}