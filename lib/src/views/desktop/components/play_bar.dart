import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:hiqradio/src/views/components/play_ctrl.dart';
import 'package:hiqradio/src/views/components/station_qr_code.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:window_manager/window_manager.dart';

class PlayBar extends StatefulWidget {
  const PlayBar({super.key});

  @override
  State<PlayBar> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  OverlayEntry? shareOverlay;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    Color dividerColor = Theme.of(context).dividerColor;

    return SizedBox(
      height: kPlayBarHeight,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              windowManager.startDragging();
            },
          ),
          Column(
            children: [
              Divider(
                height: 1,
                thickness: 1,
                color: dividerColor,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        playingStation == null
                            ? Container()
                            : StationInfo(
                                onClicked: () => {},
                                width: 200,
                                height: 54,
                                station: playingStation,
                              ),
                        _buildFuncs(),
                      ],
                    ),
                    const Center(
                      child: PlayCtrl(),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFuncs() {
    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);
    return SizedBox(
      height: 54.0,
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkClick(
            child: const Icon(IconFont.random, size: 20.0),
            onTap: () async {
              Station? station =
                  await context.read<AppCubit>().getRandomStation();
              if (station != null) {
                _play(station, playingStation, isPlaying);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkClick(
            child: const Icon(IconFont.share, size: 20.0),
            onTap: () {
              if (playingStation != null) {
                _onShareOverlay(playingStation);
              }
            },
          ),
        ),
      ]),
    );
  }

  void _closeShareOverlay() {
    if (shareOverlay != null) {
      shareOverlay!.remove();
      shareOverlay = null;
    }
  }

  void _onShareOverlay(Station playingStation) {
    double width = 300.0;
    double posLeft = (MediaQuery.of(context).size.width - width) / 2;
    double height = MediaQuery.of(context).size.height - kTitleBarHeight;

    shareOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          fit: StackFit.loose,
          children: [
            Container(
              padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => _closeShareOverlay(),
              ),
            ),
            Positioned(
              top: kTitleBarHeight,
              left: posLeft,
              width: width,
              height: height,
              child: Material(
                color: Colors.black.withOpacity(0),
                child: Dialog(
                  alignment: Alignment.center,
                  insetPadding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 0, left: 0),
                  elevation: 2.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: StationQrCode(
                    station: playingStation,
                    width: width,
                    height: height,
                    onTap: () {
                      _closeShareOverlay();
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(shareOverlay!);
  }

  void _play(Station station, Station? playingStation, bool isPlaying) {
    if (isPlaying) {
      context.read<AppCubit>().stop();
      if (playingStation != null) {
        context.read<RecentlyCubit>().updateRecently(playingStation);
      }
    }

    context.read<AppCubit>().play(station);
    context.read<RecentlyCubit>().addRecently(station);
  }
}
