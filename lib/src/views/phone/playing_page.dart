import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_qr_code.dart';
import 'package:hiqradio/src/views/phone/carplaying_page.dart';
import 'package:hiqradio/src/views/phone/components/rotate_station.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
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
    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

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
      child: RotateStation(
          station: playingStation,
          isPlaying: isPlaying,
          onClicked: (station) async {
            if (station.homepage != null) {
              Uri url = Uri.parse(station.homepage!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            }
          }),
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
              onTap: () async {
                if (isPlaying) {
                  context.read<AppCubit>().stop();
                  if (playingStation != null) {
                    context
                        .read<RecentlyCubit>()
                        .updateRecently(playingStation);
                  }
                }
                Station? station =
                    await context.read<AppCubit>().getPrevStation();
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
              onTap: () async {
                if (isPlaying) {
                  context.read<AppCubit>().stop();
                  if (playingStation != null) {
                    context
                        .read<RecentlyCubit>()
                        .updateRecently(playingStation);
                  }
                }
                Station? station =
                    await context.read<AppCubit>().getNextStation();
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

  Widget _funcVolume() {
    return _funcs(
        icon: IconFont.volume,
        text: AppLocalizations.of(context)!.cmm_volume,
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
                              AppLocalizations.of(context)!.cmm_volume,
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
                                  volume > 0 ? IconFont.volume : IconFont.mute,
                                  size: 25,
                                ),
                              ),
                              onTap: () {},
                            ),
                            Expanded(
                                child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Slider(
                                  value: volume,
                                  onChanged: (value) {
                                    context.read<AppCubit>().setVolume(value);
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
        });
  }

  Widget _funcShare(Station? playingStation) {
    Size size = MediaQuery.of(context).size;
    const padding = 40.0;
    double width = size.width - padding * 2;
    double height = size.height - padding * 4;
    return _funcs(
        icon: IconFont.share,
        text: AppLocalizations.of(context)!.cmm_share,
        onTap: () {
          if (playingStation != null) {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return Material(
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
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                });
          }
        });
  }

  Widget _funcTimer(int stopTimer) {
    return _funcs(
        icon: IconFont.timer,
        color: stopTimer > 0
            ? const Color(0XFFEA3E3C)
            : Theme.of(context).textTheme.bodyMedium!.color!,
        text: AppLocalizations.of(context)!.cfg_timer,
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
                                  AppLocalizations.of(context)!
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
                                  AppLocalizations.of(context)!.cmm_cancel,
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
                                  context.read<AppCubit>().cancelStopTimer();
                                  showToast(
                                    AppLocalizations.of(context)!
                                        .cmm_stop_time_cancel_msg,
                                    position: const ToastPosition(
                                      align: Alignment.bottomCenter,
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.cmm_confirm,
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
                                    tmpSleepTime = null;
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Text(
                                  AppLocalizations.of(context)!.cmm_stop_time,
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
                                      int ms = now.millisecondsSinceEpoch;

                                      int setMs =
                                          tmpSleepTime!.millisecondsSinceEpoch;
                                      if (setMs < ms) {
                                        setMs += (24 * 60 * 60 * 1000);
                                      }

                                      context
                                          .read<AppCubit>()
                                          .restartStopTimer(setMs);

                                      showToast(
                                        '${AppLocalizations.of(context)!.cmm_stop_time_tips}  ${DateFormat("HH:mm:ss").format(DateTime.fromMillisecondsSinceEpoch(setMs))}',
                                        position: const ToastPosition(
                                          align: Alignment.bottomCenter,
                                        ),
                                      );
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
        });
  }

  Widget _funcFav(bool isFavStation, Station? playingStation) {
    return _funcs(
        icon: isFavStation ? IconFont.favoriteFill : IconFont.favorite,
        color: isFavStation
            ? const Color(0XFFEA3E3C)
            : Theme.of(context).textTheme.bodyMedium!.color!,
        text: AppLocalizations.of(context)!.cmm_favorite,
        onTap: () {
          if (playingStation != null) {
            if (!isFavStation) {
              context.read<FavoriteCubit>().addFavorite(null, playingStation);
            } else {
              context.read<FavoriteCubit>().delFavorite(playingStation);
            }
            context.read<AppCubit>().switchFavPlayingStation();
          }
        });
  }

  // Widget _funcRecording(bool isRecording, Station? playingStation) {
  //   return _funcs(
  //       icon: IconFont.record,
  //       color: isRecording && tick.isEven
  //           ? const Color(0XFFEA3E3C)
  //           : Theme.of(context).textTheme.bodyMedium!.color!,
  //       text: AppLocalizations.of(context)!.mod_record,
  //       onTap: () async {
  //         if (playingStation != null) {
  //           String? path =
  //               await context.read<AppCubit>().getStationRecordingPath();
  //           if (path != null && !isRecording) {
  //             _doStartRecording(playingStation, path);
  //           } else {
  //             _doStopRecording();
  //           }
  //         }
  //       });
  // }

  Widget _funcs(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      Color? color}) {
    return InkClick(
      child: Column(
        children: [
          Icon(
            icon,
            size: 28.0,
            color: color,
          ),
          const SizedBox(
            height: 8.0,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 14.0),
          )
        ],
      ),
      onTap: () => onTap.call(),
    );
  }

  Widget _buildFuncs() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isFavStation =
        context.select<AppCubit, bool>((value) => value.state.isFavStation);

    int stopTimer =
        context.select<AppCubit, int>((value) => value.state.stopTimer);

    return SizedBox(
      height: 54.0,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _funcShare(playingStation),
        _funcVolume(),
        _funcTimer(stopTimer),
        _funcFav(isFavStation, playingStation),
        // _funcRecording(isRecording, playingStation),
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
            text: AppLocalizations.of(context)!.cfg_drive_mode,
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
