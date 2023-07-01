import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/record_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';

class PlayFuncs extends StatefulWidget {
  const PlayFuncs({super.key});

  @override
  State<PlayFuncs> createState() => _PlayFuncsState();
}

class _PlayFuncsState extends State<PlayFuncs> {
  Timer? recordingTimer;
  int tick = 0;

  Station? recordStation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (recordingTimer != null) {
      recordingTimer!.cancel();
      recordingTimer = null;
    }
  }

  void _startRecordingTimer() {
    if (recordingTimer == null) {
      tick = 0;
      recordingTimer =
          Timer.periodic(const Duration(milliseconds: 800), (timer) {
        setState(() {
          tick += 1;
        });
      });
    }
  }

  void _stopRecordingTimer() {
    if (recordingTimer != null) {
      tick = 0;
      recordingTimer!.cancel();
      recordingTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isFavStation =
        context.select<AppCubit, bool>((value) => value.state.isFavStation);

    bool isRecording =
        context.select<AppCubit, bool>((value) => value.state.isRecording);

    if (isRecording) {
      _startRecordingTimer();
    }
    if (isRecording &&
        playingStation != null &&
        recordStation != null &&
        playingStation.stationuuid != recordStation!.stationuuid) {
      _doStopRecording();
    }

    // int? recordingId =
    //     context.select<AppCubit, int?>((value) => value.state.recordingId);

    return Container(
      // width: 280.0,
      height: 54.0,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: InkClick(
              child: Icon(
                isFavStation ? IconFont.favoriteFill : IconFont.favorite,
                size: 23.0,
                color: isFavStation
                    ? const Color(0XFFEA3E3C)
                    : Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              onTap: () {
                if (playingStation != null) {
                  if (!isFavStation) {
                    context
                        .read<FavoriteCubit>()
                        .addFavorite(null, playingStation);
                  } else {
                    context.read<FavoriteCubit>().delFavorite(playingStation);
                  }
                  context.read<AppCubit>().switchFavPlayingStation();
                }
              },
            ),
          ),

          // const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: InkClick(
              child: Icon(
                IconFont.record,
                size: 23.0,
                color: isRecording && tick.isEven
                    ? const Color(0XFFEA3E3C)
                    : Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              onTap: () async {
                if (playingStation != null) {
                  String? path =
                      await context.read<AppCubit>().getStationRecordingPath();
                  if (path != null && !isRecording) {
                    _doStartRecording(playingStation, path);
                  } else {
                    _doStopRecording();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _doStopRecording() {
    context.read<AppCubit>().stopRecording();
    _stopRecordingTimer();
    context.read<RecordCubit>().updateRecord();
  }

  void _doStartRecording(Station station, String dest) {
    recordStation = station;
    context.read<AppCubit>().startRecording(dest);
    _startRecordingTimer();
    context.read<RecordCubit>().addRecord(station, dest);
  }
}
