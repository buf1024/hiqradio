import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/record_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_placeholder.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: Column(
        children: [
          _playIcon(),
          const Spacer(),
          _buildFuncs(),
          _playCtrl(),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);
    return AppBar(
      backgroundColor: scaffoldBackgroundColor,
      shadowColor: Colors.black.withOpacity(0),
      centerTitle: true,
      leading: InkClick(
          child: const Icon(
            Icons.arrow_back,
            size: 22,
          ),
          onTap: () {
            Navigator.of(context).pop();
          }),
      title: Column(
        children: [
          Text(
            playingStation != null ? playingStation.name : '',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16.0),
          ),
          Text(
            playingStation != null ? _getLocationText(playingStation) : '',
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(fontSize: 13.0, color: Colors.grey.withOpacity(0.8)),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: InkClick(
            child: const Icon(
              Icons.more_horiz_outlined,
              size: 25,
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _playIcon() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    Size size = MediaQuery.of(context).size;
    if (playingStation == null) {
      return SizedBox(
        height: size.width - 120.0,
        width: size.width - 120.0,
      );
    }

    return Center(
      child: Container(
        height: size.width - 120.0,
        width: size.width - 120.0,
        margin: const EdgeInsets.only(top: 90.0),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(blurRadius: 1024.0, color: Colors.black.withOpacity(0.5))
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(size.width - 120.0)),
          child: playingStation.favicon != null &&
                  playingStation.favicon!.isNotEmpty
              ? CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: playingStation.favicon!,
                  placeholder: (context, url) {
                    return StationPlaceholder(
                      height: size.width - 120.0,
                      width: size.width - 120.0,
                    );
                  },
                  errorWidget: (context, url, error) {
                    return StationPlaceholder(
                      height: size.width - 120.0,
                      width: size.width - 120.0,
                    );
                  },
                )
              : StationPlaceholder(
                  height: size.width - 120.0,
                  width: size.width - 120.0,
                ),
        ),
      ),
    );
  }

  Widget _playCtrl() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    // int? recordingId =
    //     context.select<AppCubit, int?>((value) => value.state.recordingId);

    return Container(
      height: 54.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 50.0, top: 40.0),
      child: Row(
        children: [
          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: InkClick(
              child: const Icon(
                IconFont.previous,
                size: 28.0,
                color: Color(0XFFEA3E3C),
              ),
              onTap: () {
                if (isPlaying) {
                  context.read<AppCubit>().stop();
                  if (playingStation != null) {
                    context
                        .read<RecentlyCubit>()
                        .updateRecently(playingStation);
                  }
                }
                Station? station = context.read<AppCubit>().getPrevStation();
                if (station != null) {
                  context.read<AppCubit>().play(station);
                  context.read<RecentlyCubit>().addRecently(station);
                }
              },
            ),
          ),
          InkClick(
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: const Color(0XFFEA3E3C),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      children: [
                        // 不能完全居中
                        SizedBox(
                          width: !isPlaying ? 15.0 : 12.0,
                        ),
                        Icon(
                          !isPlaying ? IconFont.play : IconFont.stop,
                          size: 28,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  if (isBuffering)
                    Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                ],
              ),
            ),
            onTap: () async {
              if (isPlaying) {
                context.read<AppCubit>().stop();
                if (playingStation != null) {
                  context.read<RecentlyCubit>().updateRecently(playingStation);
                }
              } else {
                if (playingStation != null) {
                  context.read<AppCubit>().play(playingStation);
                  context.read<RecentlyCubit>().addRecently(playingStation);
                }
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: InkClick(
              child: const Icon(
                IconFont.next,
                size: 28.0,
                color: Color(0XFFEA3E3C),
              ),
              onTap: () {
                if (isPlaying) {
                  context.read<AppCubit>().stop();
                  if (playingStation != null) {
                    context
                        .read<RecentlyCubit>()
                        .updateRecently(playingStation);
                  }
                }
                Station? station = context.read<AppCubit>().getNextStation();
                if (station != null) {
                  context.read<AppCubit>().play(station);
                  context.read<RecentlyCubit>().addRecently(station);
                }
              },
            ),
          ),
          // const Spacer(),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFuncs() {
    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);
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

    return SizedBox(
      height: 54.0,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: InkClick(
            child: Column(
              children: [
                Icon(
                  IconFont.volume,
                  size: 28.0,
                  // color: isRecording && tick.isEven
                  //     ? const Color(0XFFEA3E3C)
                  //     : Theme.of(context).textTheme.bodyMedium!.color!,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  '音量',
                  style: TextStyle(fontSize: 14.0),
                )
              ],
            ),
            onTap: () async {
              // if (playingStation != null) {
              //   String? path =
              //       await context.read<AppCubit>().getStationRecordingPath();
              //   if (path != null && !isRecording) {
              //     _doStartRecording(playingStation, path);
              //   } else {
              //     _doStopRecording();
              //   }
              // }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: InkClick(
            child: Column(
              children: [
                Icon(
                  IconFont.timer,
                  size: 28.0,
                  // color: isRecording && tick.isEven
                  //     ? const Color(0XFFEA3E3C)
                  //     : Theme.of(context).textTheme.bodyMedium!.color!,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  '定时器',
                  style: TextStyle(fontSize: 14.0),
                )
              ],
            ),
            onTap: () async {
              // if (playingStation != null) {
              //   String? path =
              //       await context.read<AppCubit>().getStationRecordingPath();
              //   if (path != null && !isRecording) {
              //     _doStartRecording(playingStation, path);
              //   } else {
              //     _doStopRecording();
              //   }
              // }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: InkClick(
            child: Column(
              children: [
                Icon(
                  isFavStation ? IconFont.favoriteFill : IconFont.favorite,
                  size: 28.0,
                  color: isFavStation
                      ? const Color(0XFFEA3E3C)
                      : Theme.of(context).textTheme.bodyMedium!.color!,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                const Text(
                  '收藏',
                  style: TextStyle(fontSize: 14.0),
                )
              ],
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: InkClick(
              child: Column(
                children: [
                  Icon(
                    IconFont.record,
                    size: 28.0,
                    color: isRecording && tick.isEven
                        ? const Color(0XFFEA3E3C)
                        : Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  const Text(
                    '录音',
                    style: TextStyle(fontSize: 14.0),
                  )
                ],
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
              }),
        ),
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

  String _getLocationText(Station station) {
    return ResManager.instance.getStationInfoText(
        station.countrycode, station.state, station.language);
  }
}
