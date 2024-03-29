import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_info.dart';

class StationIcon extends StatelessWidget {
  final VoidCallback? onClicked;
  final VoidCallback? onPlayClicked;
  final Station station;
  final bool isPlaying;
  final bool isBuffering;

  const StationIcon(
      {super.key,
      this.onClicked,
      this.onPlayClicked,
      required this.station,
      required this.isPlaying, required this.isBuffering});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      // width: 180.0,
      width: 220.0,

      child: Stack(
        children: [
          StationInfo(
            onClicked: () => onClicked?.call(),
            width: 220,
            height: 60,
            station: station,
          ),
          Positioned(
            bottom: 3.0,
            left: 3.0,
            child: Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: const Color(0XFFEA3E3C),
              ),
              child: InkClick(
                onTap: () => onPlayClicked?.call(),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          // 不能完全居中
                          SizedBox(
                            width: !isPlaying ? 9.0 : 7.0,
                          ),
                          Icon(
                            !isPlaying ? IconFont.play : IconFont.stop,
                            size: 10,
                            color: Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                        ],
                      ),
                    ),
                    if (isBuffering)
                      SizedBox(
                        height: 25.0,
                        width: 25.0,
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 2.0,
                        ),
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
