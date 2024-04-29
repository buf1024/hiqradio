import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/pair.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_placeholder.dart';
import 'package:hiqradio/src/views/phone/playing_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyPhoneRecently extends StatefulWidget {
  const MyPhoneRecently({super.key});

  @override
  State<MyPhoneRecently> createState() => _MyPhoneRecentlyState();
}

class _MyPhoneRecentlyState extends State<MyPhoneRecently>
    with AutomaticKeepAliveClientMixin {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<RecentlyCubit>().loadRecently();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Pair<Station, Recently>> recentlys =
        context.select<RecentlyCubit, List<Pair<Station, Recently>>>(
            (value) => value.state.recentlys);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _tableFuncs(),
          Expanded(
              child:
                  recentlys.isNotEmpty ? _buildRecently(recentlys) : _empty())
        ],
      ),
    );
  }

  Widget _empty() {
    bool isLoading =
        context.select<RecentlyCubit, bool>((value) => value.state.isLoading);
    if (isLoading) {
      return Center(
        child: Container(
          height: 40.0,
          width: 40.0,
          padding: const EdgeInsets.all(4.0),
          child: CircularProgressIndicator(
            strokeWidth: 1.0,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      );
    }
    return Center(
      child: Text(
        // '暂无播放记录',
        AppLocalizations.of(context)!.recently_empty,
        style: const TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
  }

  Widget _buildRecently(List<Pair<Station, Recently>> recentlys) {
    Station? playingStation = context.select<AppCubit, Station?>(
      (value) => value.state.playingStation,
    );
    bool isPlaying = context.select<AppCubit, bool>(
      (value) => value.state.isPlaying,
    );
    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);
    return ListView.builder(
      itemBuilder: (context, index) {
        Pair<Station, Recently> pair = recentlys[index];

        Station station = pair.p1;
        Recently recently = pair.p2;

        bool isStationPlaying = isPlaying &&
            playingStation!.urlResolved == station.urlResolved &&
            index == 0;

        Size winSize = MediaQuery.of(context).size;

        return Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            children: [
              GestureDetector(
                child: StationHis(
                  onClicked: () {
                    _jumpPlayingPage(isPlaying, playingStation, station);
                  },
                  width: winSize.width - 68,
                  height: 60.0,
                  station: station,
                  recently: recently,
                ),
                onTap: () {
                  _jumpPlayingPage(isPlaying, playingStation, station);
                },
                onLongPressEnd: (details) {
                  showContextMenu(details.globalPosition);
                },
              ),
              InkClick(
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    // color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          children: [
                            // 不能完全居中
                            SizedBox(
                              width: !isStationPlaying ? 4.0 : 3.0,
                            ),
                            Icon(
                              !isStationPlaying ? IconFont.play : IconFont.stop,
                              size: 12.0,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            )
                          ],
                        ),
                      ),
                      if (isBuffering && isStationPlaying)
                        Center(
                          child: SizedBox(
                            height: 30.0,
                            width: 30.0,
                            child: CircularProgressIndicator(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color!
                                  .withOpacity(0.2),
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
                      context
                          .read<RecentlyCubit>()
                          .updateRecently(playingStation);
                      if (playingStation.urlResolved != station.urlResolved) {
                        context.read<AppCubit>().play(station);
                        context.read<RecentlyCubit>().addRecently(station);
                      }
                    }
                  } else {
                    context.read<AppCubit>().play(station);
                    context.read<RecentlyCubit>().addRecently(station);
                  }
                },
              ),
            ],
          ),
        );
      },
      itemCount: recentlys.length,
      controller: scrollController,
    );
  }

  void showContextMenu(Offset offset) {
    showMenu(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        position: RelativeRect.fromLTRB(
            offset.dx, offset.dy + 5.0, offset.dx, offset.dy),
        items: [
          _popMenuItem(
            () {
              context.read<RecentlyCubit>().clearRecently();
            },
            IconFont.close,
            // '清空播放记录'
            AppLocalizations.of(context)!.recently_clear,
          ),
        ],
        elevation: 8.0);
  }

  PopupMenuItem<Never> _popMenuItem(
      VoidCallback onTap, IconData icon, String text) {
    return PopupMenuItem<Never>(
      mouseCursor: SystemMouseCursors.basic,
      height: 30.0,
      onTap: () => onTap(),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 12.0),
              child: Icon(
                icon,
                size: 16.0,
              ),
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

  void _jumpPlayingPage(
      bool isPlaying, Station? playingStation, Station station) {
    bool newPlay = true;
    if (isPlaying) {
      if (playingStation != null &&
          playingStation.urlResolved != station.urlResolved) {
        context.read<AppCubit>().stop();
        context.read<RecentlyCubit>().updateRecently(playingStation);
      } else {
        newPlay = false;
      }
    }
    if (newPlay) {
      context.read<AppCubit>().play(station);
      context.read<RecentlyCubit>().addRecently(station);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PlayingPage(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class StationHis extends StatelessWidget {
  final VoidCallback? onClicked;
  final double width;
  final double height;
  final Station station;
  final Recently recently;
  const StationHis(
      {super.key,
      this.onClicked,
      required this.width,
      required this.height,
      required this.station,
      required this.recently});

  @override
  Widget build(BuildContext context) {
    // String sDuration = '';
    // if (recently.endTime != null) {
    //   var duration = DateTime.fromMillisecondsSinceEpoch(recently.endTime!)
    //       .difference(DateTime.fromMillisecondsSinceEpoch(recently.startTime));
    //   sDuration =
    //       "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
    // }

    return SizedBox(
      height: height,
      width: width,
      child: Row(
        children: [
          InkClick(
            onTap: () => onClicked?.call(),
            child: SizedBox(
              height: height,
              width: height,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: station.favicon != null && station.favicon!.isNotEmpty
                    ? CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: station.favicon!,
                        placeholder: (context, url) {
                          return const StationPlaceholder(
                            height: 60.0,
                            width: 60.0,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const StationPlaceholder(
                            height: 60.0,
                            width: 60.0,
                          );
                        },
                      )
                    : const StationPlaceholder(
                        height: 60.0,
                        width: 60.0,
                      ),
              ),
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              SizedBox(
                width: width - height - 8.0,
                child: Text(
                  station.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(
                width: width - height - 8.0,
                child: Text(
                  '开始: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(
                    DateTime.fromMillisecondsSinceEpoch(recently.startTime),
                  )}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.withOpacity(0.8)),
                ),
              ),
              SizedBox(
                width: width - height - 8.0,
                child: Text(
                  recently.endTime != null
                      ? '结束: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              recently.endTime!),
                        )}'
                      : '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.withOpacity(0.8)),
                ),
              ),
              // SizedBox(
              //   width: width - height - 8.0,
              //   child: Text(
              //     recently.endTime != null ? '时长: $sDuration' : '',
              //     overflow: TextOverflow.ellipsis,
              //     style: TextStyle(
              //         fontSize: 12, color: Colors.grey.withOpacity(0.8)),
              //   ),
              // ),
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }
}
