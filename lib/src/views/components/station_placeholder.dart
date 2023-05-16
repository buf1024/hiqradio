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
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.blueGrey,
        Colors.grey,
      ])),
      child: Center(
        child: Icon(IconFont.station,
            // size: 25.0,
            size: height * 0.4,
            color: Colors.white.withOpacity(0.8)),
      ),
    );
  }
}
