import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveAnimationWidget extends StatefulWidget {
  final String animationPath;
  final String stateMachine;
  final double height;
  final double width;

  const RiveAnimationWidget({
    Key? key,
    required this.animationPath,
    required this.stateMachine,
    this.height = 100,
    this.width = 100,
  }) : super(key: key);

  @override
  _RiveAnimationWidgetState createState() => _RiveAnimationWidgetState();
}

class _RiveAnimationWidgetState extends State<RiveAnimationWidget> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation(widget.stateMachine); // 🎬 Default animation state
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: RiveAnimation.asset(
        widget.animationPath,
        controllers: [_controller],
        fit: BoxFit.contain,
      ),
    );
  }
}
