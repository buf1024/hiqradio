import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/components/play_ctrl.dart';
import 'package:hiqradio/src/views/desktop/components/station_info.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';

class PlayBar extends StatefulWidget {
  const PlayBar({super.key});

  @override
  State<PlayBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<PlayBar> {
  @override
  Widget build(BuildContext context) {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    Color dividerColor = Theme.of(context).dividerColor;

    return SizedBox(
      height: kPlayBarHeight,
      child: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: dividerColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
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
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
        //   child: InkClick(
        //     child: const Icon(IconFont.volume, size: 20.0),
        //     onTap: () {},
        //   ),
        // ),
      ]),
    );
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
