import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:text_scroll/text_scroll.dart';

class CarPlayingPage extends StatefulWidget {
  const CarPlayingPage({super.key});

  @override
  State<CarPlayingPage> createState() => _CarPlayingPageState();
}

class _CarPlayingPageState extends State<CarPlayingPage> {
  bool isVertical = true;

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
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: isVertical
              ? Column(
                  children: [
                    _playHead(),
                    _playInfo(),
                    _playCtrl(),
                    const Spacer(),
                    _playMemo()
                  ],
                )
              : Row(
                  children: [
                    _playHeadHorizontal(),
                    Expanded(
                      child: Column(
                        children: [
                          _playInfo(),
                          Expanded(child: _playCtrl()),
                        ],
                      ),
                    ),
                    _playMemoHorizontal()
                  ],
                ),
        ),
        onWillPop: () {
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

          return Future(() => true);
        });
  }

  Widget _playHead() {
    bool isFavStation =
        context.select<AppCubit, bool>((value) => value.state.isFavStation);

    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);
    return SizedBox(
      height: 120.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkClick(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: const Icon(
                IconFont.close,
                size: 43.0,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown
              ]);
            },
          ),
          InkClick(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: Icon(
                isFavStation ? IconFont.favoriteFill : IconFont.favorite,
                size: 45.0,
                color: isFavStation
                    ? const Color(0XFFEA3E3C)
                    : Theme.of(context).textTheme.bodyMedium!.color!,
              ),
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
        ],
      ),
    );
  }

  Widget _playHeadHorizontal() {
    bool isFavStation =
        context.select<AppCubit, bool>((value) => value.state.isFavStation);

    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);
    return SizedBox(
      width: 80.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkClick(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: const Icon(
                IconFont.close,
                size: 43.0,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown
              ]);
            },
          ),
          InkClick(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: Icon(
                isFavStation ? IconFont.favoriteFill : IconFont.favorite,
                size: 45.0,
                color: isFavStation
                    ? const Color(0XFFEA3E3C)
                    : Theme.of(context).textTheme.bodyMedium!.color!,
              ),
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
        ],
      ),
    );
  }

  Widget _playInfo() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(
          top: isVertical ? size.height / 3.0 : 35.0, left: 10.0, right: 10.0),
      child: playingStation != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextScroll(playingStation.name,
                      style: TextStyle(
                          fontSize: 40.0,
                          color:
                              Theme.of(context).textTheme.bodyMedium!.color!),
                      velocity: const Velocity(pixelsPerSecond: Offset(20, 0))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _getLocationText(playingStation),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18.0, color: Colors.grey.withOpacity(0.8)),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _playCtrl() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Row(
        children: [
          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: InkClick(
              child: const Icon(
                IconFont.previous,
                size: 58.0,
                // color: Color(0XFFEA3E3C),
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
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    width: 3.0,
                    color: Theme.of(context).textTheme.bodyMedium!.color!),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      children: [
                        // 不能完全居中
                        SizedBox(
                          width: !isPlaying ? 25.0 : 17.0,
                        ),
                        Icon(
                          !isPlaying ? IconFont.play : IconFont.stop,
                          size: 58,
                          color: Theme.of(context).textTheme.bodyMedium!.color!,
                        )
                      ],
                    ),
                  ),
                  if (isBuffering)
                    Center(
                      child: SizedBox(
                        height: 80.0,
                        width: 80.0,
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
                size: 58.0,
                // color: Color(0XFFEA3E3C),
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

  Widget _playMemo() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 15.0),
            child: Icon(
              IconFont.car,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          InkClick(
            child: Container(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(isVertical
                  ? IconFont.rotateHorizontal
                  : IconFont.rotateVertical),
            ),
            onTap: () {
              if (isVertical) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight
                ]);
              } else {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown
                ]);
              }
              setState(() {
                isVertical = !isVertical;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _playMemoHorizontal() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      width: 60.0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 25.0),
            child: Icon(
              IconFont.car,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          InkClick(
            child: Container(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Icon(isVertical
                  ? IconFont.rotateHorizontal
                  : IconFont.rotateVertical),
            ),
            onTap: () {
              if (isVertical) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight
                ]);
              } else {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown
                ]);
              }
              setState(() {
                isVertical = !isVertical;
              });
            },
          )
        ],
      ),
    );
  }

  String _getLocationText(Station station) {
    return ResManager.instance.getStationInfoText(
        station.countrycode, station.state, station.language);
  }
}
