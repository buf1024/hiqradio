import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/play_ctrl.dart';
import 'package:hiqradio/src/views/components/station_info.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: _playingBar(),
        ),
      ),
    );
  }

  Widget _playingBar() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        playingStation == null
            ? Container(
              height: size.height * 0.75,
            )
            :Container(
              height: size.height* 0.75,
              child: StationInfo(
                onClicked: () => {},
                width: 200,
                height: 54,
                station: playingStation,
              ),
            )
             ,
        // _buildFuncs(),
        const PlayCtrl()
      ],
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
