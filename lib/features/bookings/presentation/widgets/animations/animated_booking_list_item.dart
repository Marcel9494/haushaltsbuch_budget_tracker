import 'package:flutter/material.dart';

class AnimatedBookingListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedBookingListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedBookingListItem> createState() => _AnimatedBookingListItemState();
}

class _AnimatedBookingListItemState extends State<AnimatedBookingListItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Verzögerung pro Block
    Future.delayed(Duration(milliseconds: widget.index * 10), () {
      if (mounted) {
        _controller.forward();
      }
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
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
