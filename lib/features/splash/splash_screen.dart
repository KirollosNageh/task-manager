// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../auth/presentation/controllers/auth_controller.dart';

// /// Shown briefly on app start. AuthController's onInit() binds to
// /// FirebaseAuth's authStateChanges() stream and redirects automatically
// /// (see AuthController._handleAuthChange) — this screen just needs to
// /// exist as the initial route so there's something to redirect FROM.
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Ensures AuthController exists (and its stream binds) as soon as the
//     // app starts, even before the login screen's own binding would run.
//     Get.put(AuthController(), permanent: true);

//     return const Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.check_circle_outline, size: 64),
//             SizedBox(height: 16),
//             Text('Task Manager'),
//             SizedBox(height: 24),
//             CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/presentation/controllers/auth_controller.dart';

/// Splash screen shown on app start.
///
/// AuthController remains responsible for authentication state
/// and routing. This screen only handles the splash UI/animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;

  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();

    // Main splash animation: 2.5 seconds, then stops.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    // Loading dots animation.
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    // Stop the dots after 2.5 seconds.
    _stopTimer = Timer(
      const Duration(milliseconds: 2500),
      () {
        if (!mounted) return;

        _dotsController.stop();
        _dotsController.value = 1.0;
      },
    );
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep AuthController behavior exactly as before.
    Get.put(AuthController(), permanent: true);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==========================================================
          // Ambient background - top left
          // ==========================================================

          Positioned(
            top: -180,
            left: -80,
            child: _buildAmbientCircle(),
          ),

          // ==========================================================
          // Ambient background - bottom right
          // ==========================================================

          Positioned(
            bottom: -180,
            right: -80,
            child: _buildAmbientCircle(),
          ),

          // ==========================================================
          // Main content
          // ==========================================================

          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                // Smooth pulse over 2.5 seconds.
                final scale = Tween<double>(
                  begin: 0.92,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                );

                return Transform.scale(
                  scale: scale.value,
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ====================================================
                  // Logo
                  // ====================================================

                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ====================================================
                  // App name
                  // ====================================================

                  const Text(
                    'Task Manager',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.64,
                      color: Color(0xFF3525CD),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ====================================================
                  // Loading dots
                  // ====================================================

                  _LoadingDots(
                    controller: _dotsController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientCircle() {
    return IgnorePointer(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0F3FF).withOpacity(0.60),
        ),
      ),
    );
  }
}

// ====================================================================
// Loading Dots
// ====================================================================

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 20,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final progress = controller.value;

          // First dot: scale 0 -> 1
          final dot1Scale = progress < 0.5
              ? progress * 2
              : 1.0;

          // Middle dots: move 24px
          final movement = progress * 24;

          // Last dot: scale 1 -> 0
          final dot4Scale = 1.0 - progress;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Dot 1
              Positioned(
                left: 8,
                top: 2,
                child: Transform.scale(
                  scale: dot1Scale,
                  child: _dot(0.50),
                ),
              ),

              // Dot 2
              Positioned(
                left: 8 + movement,
                top: 2,
                child: _dot(0.80),
              ),

              // Dot 3
              Positioned(
                left: 32 + movement,
                top: 2,
                child: _dot(0.80),
              ),

              // Dot 4
              Positioned(
                left: 56,
                top: 2,
                child: Transform.scale(
                  scale: dot4Scale,
                  child: _dot(0.50),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dot(double opacity) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4F46E5).withOpacity(opacity),
      ),
    );
  }
}