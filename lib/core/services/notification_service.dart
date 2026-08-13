import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../router/app_routes.dart';

/// Top-level function (required by FCM) that handles messages received
/// while the app is fully terminated or in the background. Must be a
/// top-level or static function, and must be registered BEFORE runApp()
/// in main.dart via FirebaseMessaging.onBackgroundMessage(...).
///
/// Note: we don't need to display anything here ourselves — Android shows
/// the system notification automatically for messages that include a
/// `notification` payload, even while this handler runs. This handler is
/// where you'd do background data processing (e.g. syncing), which we
/// don't need for this app.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Intentionally left lightweight — see note above.
}

/// Centralizes all FCM logic: permission request, token generation +
/// storage, foreground/background message handling, and notification-tap
/// navigation. Called once, right after a successful login (see
/// AuthController._handleAuthChange), since a token is only meaningful
/// once we know which user to attach it to.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return; // avoid double-registering listeners on hot navigation
    _initialized = true;

    await _requestPermission();
    await _saveTokenForCurrentUser();

    // Token can rotate (e.g. app reinstall, token expiry) — keep Firestore in sync.
    _messaging.onTokenRefresh.listen((_) => _saveTokenForCurrentUser());

    _setupForegroundHandler();
    _setupClickHandlers();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _saveTokenForCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true), // never overwrite email/createdAt set at registration
    );
  }

  /// App is open and in the foreground when the message arrives.
  /// The OS does NOT show a system banner in this case, so we surface
  /// it ourselves with a snackbar.
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // TEMP DEBUG — remove after confirming this fires.
      // ignore: avoid_print
      print('📩 onMessage fired: ${message.notification?.title} / data=${message.data}');

      final title = message.notification?.title ?? 'New notification';
      final body = message.notification?.body ?? '';
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    });
  }

  /// Handles the user TAPPING a notification in two situations:
  /// 1) App was in background -> onMessageOpenedApp fires directly.
  /// 2) App was fully terminated -> getInitialMessage() returns the
  ///    message that launched the app (checked once on startup).
  void _setupClickHandlers() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleNotificationTap(message);
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Expects a data payload like {"type": "task", "taskId": "abc123"}.
    // We currently route to the task list for any task-related notification;
    // this is the single place to extend if a dedicated task-details screen
    // is added later.
    final type = message.data['type'];
    if (type == 'task') {
      Get.toNamed(AppRoutes.home);
    }
  }
}