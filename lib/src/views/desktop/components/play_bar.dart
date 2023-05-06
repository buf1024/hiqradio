import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/views/desktop/components/play_ctrl.dart';
import 'package:hiqradio/src/views/desktop/components/station_info.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:flutter/services.dart' show rootBundle;

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
    return SizedBox(
      height: 54.0,
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkClick(
            child: const Icon(IconFont.random, size: 20.0),
            onTap: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkClick(
            child: const Icon(IconFont.volume, size: 20.0),
            onTap: () {},
          ),
        ),
      ]),
    );
  }
}
