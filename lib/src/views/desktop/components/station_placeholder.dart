import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';

class StationPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  const StationPlaceholder(
      {super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.grey.withOpacity(0.3),
        Colors.grey.withOpacity(0.5),
      ])),
      child: Center(
        child: Icon(IconFont.station,
            // size: 25.0,
            size: height * 0.4),
      ),
    );
    ;
  }
}
