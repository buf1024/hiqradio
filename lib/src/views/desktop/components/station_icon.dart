import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/views/desktop/components/station_info.dart';
import 'package:url_launcher/url_launcher.dart';

class StationIcon extends StatelessWidget {
  final VoidCallback? onClicked;
  final VoidCallback? onPlayClicked;

  const StationIcon({super.key, this.onClicked, this.onPlayClicked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      width: 180.0,
      child: Stack(
        children: [
          StationInfo(
              onClicked: () => onClicked?.call(), width: 180, height: 60),
          Positioned(
            bottom: 3.0,
            left: 3.0,
            child: Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.red.withOpacity(0.9),
              ),
              child: InkClick(
                onTap: () => onPlayClicked?.call(),
                child: Row(
                  children: [
                    // 不能完全居中
                    const SizedBox(
                      width: 9.0,
                    ),
                    Icon(
                      IconFont.play,
                      size: 10,
                      color: Colors.white.withOpacity(0.9),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
