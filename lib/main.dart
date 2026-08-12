import 'package:flutter/material.dart';
import 'app.dart';
 
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() will be added here in the Firebase-init step.
  runApp(const TaskManagerApp());
}