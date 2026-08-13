import 'package:flutter/material.dart';

/// Lightweight implicit entrance animation (fade + slight upward slide),
/// used to stagger-in list items. Built with Flutter's own animation
/// classes — no external animation package needed for something this
/// simple.
class FadeSlideIn extends StatefulWidget {
  final Widget child;

  /// Used to stagger successive items' entrance. Capped internally so
  /// long lists don't produce absurdly long delays.
  final int index;

  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Cap the stagger multiplier so item #200 doesn't wait several
    // seconds before appearing — only the first ~10 items visibly stagger.
    final delay = Duration(milliseconds: 25 * (widget.index % 10));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}