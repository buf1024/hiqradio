import 'package:flutter/material.dart';

class InkClick extends StatelessWidget {
  final VoidCallback? onTap;
  final Function(Offset, Offset)? onTapDown;
  final VoidCallback? onLongPress;
  final Widget child;
  const InkClick({
    super.key,
    this.onTap,
    this.onTapDown,
    this.onLongPress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        focusColor: Colors.black.withOpacity(0),
        hoverColor: Colors.black.withOpacity(0),
        highlightColor: Colors.black.withOpacity(0),
        radius: 0.0,
        child: child,
        onTap: () => onTap?.call(),
        onLongPress: () => onLongPress?.call(),
        onTapDown: (details) =>
            onTapDown?.call(details.globalPosition, details.localPosition));
  }
}
