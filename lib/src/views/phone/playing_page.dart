import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/record_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_placeholder.dart';
import 'package:hiqradio/src/views/phone/carplaying_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:text_scroll/text_scroll.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  Timer? recordingTimer;
  int tick = 0;

  Station? recordStation;

  double volume = 0.0;
  DateTime? tmpSleepTime;

  @override
  void initState() {
    super.initState();
    volume = context.read<AppCubit>().getVolume();
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
          TextScroll(playingStation != null ? playingStation.name : '',
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).textTheme.bodyMedium!.color!),
              velocity: const Velocity(pixelsPerSecond: Offset(20, 0))),
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
            onTap: () async {
              _showFuncMenu();
            },
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
                          width: !isPlaying ? 14.0 : 11.0,
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
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isFavStation =
        context.select<AppCubit, bool>((value) => value.state.isFavStation);

    bool isRecording =
        context.select<AppCubit, bool>((value) => value.state.isRecording);

    int stopTimer =
        context.select<AppCubit, int>((value) => value.state.stopTimer);

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
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: InkClick(
            child: Column(
              children: [
                const Icon(
                  IconFont.volume,
                  size: 28.0,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  AppLocalizations.of(context).cmm_volume,
                  style: const TextStyle(fontSize: 14.0),
                )
              ],
            ),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  elevation: 2.0,
                  backgroundColor: Colors.black.withOpacity(0),
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return Container(
                        height: 120,
                        decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0))),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkClick(
                                  child: const SizedBox(
                                    height: 50.0,
                                    width: 50.0,
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 25,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Text(
                                  AppLocalizations.of(context).cmm_volume,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                InkClick(
                                  child: const SizedBox(
                                    height: 50.0,
                                    width: 50.0,
                                    child: Icon(
                                      Icons.done_outlined,
                                      size: 25,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkClick(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Icon(
                                      volume > 0
                                          ? IconFont.volume
                                          : IconFont.mute,
                                      size: 25,
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                                Expanded(
                                    child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Slider(
                                      value: volume,
                                      onChanged: (value) {
                                        context
                                            .read<AppCubit>()
                                            .setVolume(value);
                                        setState(() {
                                          volume = value;
                                        });
                                      }),
                                ))
                              ],
                            )
                          ],
                        ),
                      );
                    });
                  });
              setState(() {});
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: InkClick(
            child: Column(
              children: [
                Icon(
                  IconFont.timer,
                  size: 28.0,
                  color: stopTimer > 0
                      ? const Color(0XFFEA3E3C)
                      : Theme.of(context).textTheme.bodyMedium!.color!,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  AppLocalizations.of(context).cfg_timer,
                  style: const TextStyle(fontSize: 14.0),
                )
              ],
            ),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  elevation: 2.0,
                  enableDrag: false,
                  backgroundColor: Colors.black.withOpacity(0),
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      if (stopTimer > 0) {
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 5.0),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .cmm_stop_time_confirm,
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      DateFormat("HH:mm:ss").format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              stopTimer)),
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.red.withOpacity(0.8)),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MaterialButton(
                                    color: Theme.of(context)
                                        .cardColor
                                        .withOpacity(0.8),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      // '取消',
                                      AppLocalizations.of(context).cmm_cancel,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  MaterialButton(
                                    color: Colors.red.withOpacity(0.8),
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      tmpSleepTime = null;
                                      context
                                          .read<AppCubit>()
                                          .cancelStopTimer();
                                    },
                                    child: Text(
                                      AppLocalizations.of(context).cmm_confirm,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return WillPopScope(
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0))),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkClick(
                                      child: const SizedBox(
                                        height: 50.0,
                                        width: 50.0,
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 25,
                                        ),
                                      ),
                                      onTap: () {
                                        tmpSleepTime = null;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    Text(
                                      AppLocalizations.of(context)
                                          .cmm_stop_time,
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    InkClick(
                                      child: const SizedBox(
                                        height: 50.0,
                                        width: 50.0,
                                        child: Icon(
                                          Icons.done_outlined,
                                          size: 25,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        if (tmpSleepTime != null) {
                                          var now = DateTime.now();
                                          int ms = (now.hour * 24 +
                                                  now.minute * 60 +
                                                  now.second) *
                                              1000;

                                          int setMs = tmpSleepTime!
                                              .millisecondsSinceEpoch;
                                          if (setMs < ms) {
                                            setMs += (24 * 60 * 60 * 1000);
                                          }

                                          context
                                              .read<AppCubit>()
                                              .restartStopTimer(setMs);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                TimePickerSpinner(
                                  time: tmpSleepTime,
                                  is24HourMode: true,
                                  isShowSeconds: true,
                                  normalTextStyle: TextStyle(
                                      fontSize: 24,
                                      color: Theme.of(context).hintColor),
                                  highlightedTextStyle: TextStyle(
                                      fontSize: 24,
                                      color: Colors.red.withOpacity(0.9)),
                                  spacing: 5,
                                  itemHeight: 45,
                                  isForce2Digits: true,
                                  onTimeChange: (time) {
                                    setState(() {
                                      tmpSleepTime = time;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          onWillPop: () {
                            tmpSleepTime = null;
                            return Future(
                              () => true,
                            );
                          });
                    });
                  });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
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
                Text(
                  AppLocalizations.of(context).cmm_favorite,
                  style: const TextStyle(fontSize: 14.0),
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
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
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
                  Text(
                    AppLocalizations.of(context).mod_record,
                    style: const TextStyle(fontSize: 14.0),
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

  void _jumpCarPlay() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CarPlayingPage()),
    );
  }

  void _showFuncMenu() async {
    Size size = MediaQuery.of(context).size;
    int? value = await showMenu(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        position:
            RelativeRect.fromLTRB(size.width - 80.0, 80.0, size.width, 280.0),
        items: [
          _popMenuItem(
            enabled: true,
            value: 0,
            onTap: () {},
            icon: const Icon(
              IconFont.car,
              size: 18.0,
            ),
            text: AppLocalizations.of(context).cfg_drive_mode,
          ),
          // _popMenuItem(
          //     enabled: true,
          //     onTap: () {},
          //     icon: const Icon(
          //       IconFont.recently,
          //       size: 18.0,
          //     ),
          //     text: '收听历史'),
          // _popMenuItem(
          //     enabled: true,
          //     onTap: () {},
          //     icon: const Icon(
          //       IconFont.record,
          //       size: 18.0,
          //     ),
          //     text: '录音记录'),
          // _popMenuItem(
          //     enabled: true,
          //     onTap: () {},
          //     icon: const Icon(
          //       IconFont.share,
          //       size: 18.0,
          //     ),
          //     text: '电台分享'),
        ],
        elevation: 8.0);

    if (value != null && value == 0) {
      _jumpCarPlay();
    }
  }

  PopupMenuItem<int> _popMenuItem(
      {required bool enabled,
      required int value,
      required VoidCallback onTap,
      required Widget icon,
      required String text}) {
    return PopupMenuItem<int>(
      mouseCursor: SystemMouseCursors.basic,
      height: 40.0,
      enabled: enabled,
      value: value,
      onTap: () => onTap(),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 12.0),
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: Text(
                text,
                style: const TextStyle(fontSize: 16.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getLocationText(Station station) {
    return ResManager.instance.getStationInfoText(
        station.countrycode, station.state, station.language);
  }
}
