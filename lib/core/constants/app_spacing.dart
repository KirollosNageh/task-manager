/// Centralized spacing scale. Use these instead of raw numbers
/// (e.g. `SizedBox(height: AppSpacing.md)` not `SizedBox(height: 16)`)
/// so the whole app's rhythm can be tuned from one place.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Common radius values
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusFull = 999;
}