import 'package:flutter/material.dart';

class MediaButtonController extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final void Function()? func;

  const MediaButtonController({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    required this.func,
  });

  @override
  State<StatefulWidget> createState() {
    return _MediaButtonControllerState();
  }
}

class _MediaButtonControllerState extends State<MediaButtonController> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.func,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
