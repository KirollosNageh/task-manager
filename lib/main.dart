import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Explicit for clarity, even though it's the default: Firestore caches
  // reads locally and queues writes made while offline, syncing them
  // automatically once connectivity returns. Combined with
  // metadata.isFromCache (used in TaskRepository/TaskController), this is
  // the entire offline-handling story — no extra package required.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Must be registered here, before runApp(), and must reference a
  // top-level function — this is what lets FCM wake the app to process
  // messages while it's backgrounded or fully killed.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Independent of login state (unlike NotificationService/FCM, which
  // needs a user id to attach a token to) — due-date reminders are purely
  // on-device, so this can initialize immediately at startup.
  await LocalNotificationService().init();

  runApp(const TaskManagerApp());
}