import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

/// Standard "nothing here yet" state, reusable for tasks, search results,
/// filtered lists, etc. — any screen that can legitimately show zero items.
class EmptyStateWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _verticalAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _verticalAnimation = Tween<double>(
      begin: 0,
      end: -12,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _verticalAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    _verticalAnimation.value,
                  ),
                  child: child,
                );
              },
              child: Icon(
                widget.icon,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (widget.action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              widget.action!,
            ],
          ],
        ),
      ),
    );
  }
}