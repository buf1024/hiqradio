import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MySlidableAction extends StatelessWidget {
  final bool isFirst;
  final bool isEnd;
  final Color color;
  final IconData icon;
  final double? iconSize;
  final VoidCallback? onPressed;
  const MySlidableAction(
      {super.key,
      required this.isFirst,
      required this.isEnd,
      required this.color,
      required this.icon,
      this.onPressed,
      this.iconSize});

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      backgroundColor: Colors.black.withOpacity(0),
      padding: const EdgeInsets.all(0),
      onPressed: (BuildContext context) {
        onPressed?.call();
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 70,
              alignment: Alignment.center,
              margin: _margin(),
              // (isFirst),
              decoration: BoxDecoration(
                color: color,
                borderRadius: _borderRadius(),
              ),
              child: Icon(icon, color: Colors.white, size: iconSize ?? 28),
            ),
          )
        ],
      ),
    );
  }

  EdgeInsetsGeometry? _margin() {
    if (isFirst && isEnd) {
      return const EdgeInsets.only(left: 5, right: 5);
    }
    if (isFirst) {
      return const EdgeInsets.only(left: 5);
    }
    if (isEnd) {
      return const EdgeInsets.only(right: 5);
    }
    return null;
  }

  BorderRadiusGeometry? _borderRadius() {
    if (isFirst && isEnd) {
      return const BorderRadius.all(Radius.circular(5.0));
    }
    if (isFirst) {
      return const BorderRadius.only(
          topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0));
    }
    if (isEnd) {
      return const BorderRadius.only(
          topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0));
    }
    return null;
  }
}
