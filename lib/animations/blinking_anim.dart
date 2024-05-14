import 'package:flutter/material.dart';

class BlinkingAnim extends StatefulWidget {
  final Widget widget;
  BlinkingAnim({required this.widget});

  @override
  State<BlinkingAnim> createState() => _blinkingAnimState();
}

class _blinkingAnimState extends State<BlinkingAnim>
    with TickerProviderStateMixin {
  late Animation<double> fadeAnim;

  late AnimationController fadeAnimController;

  @override
  void dispose() {
    fadeAnimController
        .stop(); // Stop the controller when the widget is disposed
    fadeAnimController.dispose(); // Then dispose of the controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fadeAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: fadeAnimController, curve: Curves.ease));

    fadeAnimController.forward();
    fadeAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        fadeAnimController.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        fadeAnimController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: widget.widget,
    );
  }
}
