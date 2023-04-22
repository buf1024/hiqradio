import 'package:flutter/material.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';

class NavContent extends StatefulWidget {
  final Widget leftChild;
  final Widget rightChild;

  final ValueChanged? onContentResizeCallback;

  const NavContent(
      {super.key,
      required this.leftChild,
      required this.rightChild,
      this.onContentResizeCallback});

  @override
  State<NavContent> createState() => _NavContentState();
}

class _NavContentState extends State<NavContent> {
  double width = 220;

  @override
  void initState() {
    super.initState();
    width = kDefNavContentWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: widget.leftChild,
        ),
        Expanded(
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      width += details.delta.dx;
                      if (width <= kMinNavContentWidth) {
                        width = kMinNavContentWidth;
                      }
                    });
                    widget.onContentResizeCallback?.call(width);
                  },
                  child: VerticalDivider(
                    width: 2,
                    thickness: 2,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              widget.rightChild
            ],
          ),
        )
      ],
    );
  }
}
