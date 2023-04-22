import 'package:flutter/material.dart';

class TabTitleWidget extends StatefulWidget {
  final ValueChanged<Offset>? onSecondaryTap;
  final VoidCallback? onTap;
  final VoidCallback? onCloseTap;
  final String title;
  final String? tooltip;
  final bool isActive;

  final bool? noPrefix;
  final bool? noClose;

  const TabTitleWidget(
      {super.key,
      this.onSecondaryTap,
      this.onCloseTap,
      required this.title,
      this.tooltip,
      required this.isActive,
      this.onTap,
      this.noPrefix,
      this.noClose});

  @override
  State<TabTitleWidget> createState() => _TabTitleWidgetState();
}

class _TabTitleWidgetState extends State<TabTitleWidget> {
  Widget _buildPrefix() {
    if (widget.noPrefix != null && widget.noPrefix!) {
      return Container();
    }
    return const Icon(
      Icons.description_outlined,
      size: 15.0,
    );
  }

  Widget _buildSuffix() {
    if (widget.noClose != null && widget.noClose!) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        widget.onCloseTap?.call();
      },
      child: const Icon(
        Icons.close_outlined,
        size: 15.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        widget.onSecondaryTap?.call(details.globalPosition);
      },
      onTap: () {
        widget.onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isActive ? Colors.grey.withOpacity(0.2) : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Row(
          children: [
            _buildPrefix(),
            Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
            ),
            _buildSuffix()
          ],
        ),
      ),
    );
  }
}
