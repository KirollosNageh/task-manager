import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Holds app-wide UI preferences. Currently just dark mode, kept as its
/// own controller (rather than bolted onto AuthController or TaskController)
/// since it's unrelated to either feature and may grow later (e.g. locale).
///
/// Note: this uses in-memory state only, so the preference resets on app
/// restart. Persisting it (e.g. with shared_preferences) is a natural next
/// step but was left out to avoid adding a dependency purely for this
/// bonus feature.
class SettingsController extends GetxController {
  final themeMode = ThemeMode.light.obs;

  void toggleDarkMode() {
    themeMode.value =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
}