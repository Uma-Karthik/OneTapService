import 'package:flutter/material.dart';

/// Wraps any widget with pointer cursor + smooth scale/opacity hover effect.
/// Works on web (mouse) and degrades gracefully on touch.
class HoverWidget extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final double hoverOpacity;
  final Duration duration;
  final VoidCallback? onTap;

  const HoverWidget({
    super.key,
    required this.child,
    this.hoverScale = 1.04,
    this.hoverOpacity = 0.85,
    this.duration = const Duration(milliseconds: 180),
    this.onTap,
  });

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.96 : (_hovered ? widget.hoverScale : 1.0);
    final opacity = _hovered ? widget.hoverOpacity : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedOpacity(
          opacity: opacity,
          duration: widget.duration,
          child: AnimatedScale(
            scale: scale,
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
