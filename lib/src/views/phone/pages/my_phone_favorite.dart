import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/phone/playing_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyPhoneFavorite extends StatefulWidget {
  const MyPhoneFavorite({super.key});

  @override
  State<MyPhoneFavorite> createState() => _MyPhoneFavoriteState();
}

class _MyPhoneFavoriteState extends State<MyPhoneFavorite>
    with AutomaticKeepAliveClientMixin {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    String? groupName = context.read<FavoriteCubit>().getLoadedGroup();
    context.read<FavoriteCubit>().loadFavorite(groupName: groupName);
    context.read<FavoriteCubit>().loadGroups();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Station> stations = context.select<FavoriteCubit, List<Station>>(
      (value) => value.state.stations,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: stations.isNotEmpty ? _buildFavorite(stations) : _empty())
        ],
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

  Widget _buildFavorite(List<Station> stations) {
    Station? playingStation = context.select<AppCubit, Station?>(
      (value) => value.state.playingStation,
    );
    bool isPlaying = context.select<AppCubit, bool>(
      (value) => value.state.isPlaying,
    );
    FavGroup? group = context.select<FavoriteCubit, FavGroup?>(
      (value) => value.state.group,
    );
    List<FavGroup> groups = context.select<FavoriteCubit, List<FavGroup>>(
      (value) => value.state.groups,
    );

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    Size winSize = MediaQuery.of(context).size;

    return ListView.builder(
      itemBuilder: (context, index) {
        Station station = stations[index];
        bool isStationPlaying =
            isPlaying && playingStation!.urlResolved == station.urlResolved;

        return Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            children: [
              GestureDetector(
                child: StationInfo(
                  onClicked: () {
                    _jumpPlayingPage(isPlaying, playingStation, station);
                  },
                  width: winSize.width - 68,
                  height: 60,
                  station: station,
                ),
                onTap: () {
                  _jumpPlayingPage(isPlaying, playingStation, station);
                },
                onLongPressEnd: (details) async {
                  List<String> data = groups.map((e) => e.name).toList();
                  List<String> sSelected = await context
                      .read<FavoriteCubit>()
                      .loadStationGroup(station);
                  _showContextMenu(
                      details.globalPosition,
                      station,
                      playingStation != null &&
                          playingStation.urlResolved == station.urlResolved &&
                          isPlaying,
                      group,
                      data,
                      sSelected);
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
      itemCount: stations.length,
      controller: scrollController,
    );
  }

  Widget _empty() {
    return Center(
      child: Text(
        // '空空如也',
        AppLocalizations.of(context).mine_empty,
        style: const TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
  }

  void _showContextMenu(Offset offset, Station station, bool isPlaying,
      FavGroup? group, List<String> data, List<String> selected) {
    showMenu(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        position: RelativeRect.fromLTRB(
            offset.dx, offset.dy + 5.0, offset.dx, offset.dy),
        items: [
          // _popMenuItem(() {}, IconFont.search, '搜索'),
          _popMenuItem(
              enabled: true,
              onTap: () {
                if (isPlaying) {
                  context.read<AppCubit>().stop();
                  context.read<RecentlyCubit>().updateRecently(station);
                } else {
                  context.read<AppCubit>().play(station);
                  context.read<RecentlyCubit>().addRecently(station);
                }
              },
              icon: isPlaying ? IconFont.stop : IconFont.play,
              text: isPlaying
                  ?
                  // '停止'
                  AppLocalizations.of(context).cmm_stop
                  :
                  // '播放'
                  AppLocalizations.of(context).cmm_play),

          _popMenuItem(
              enabled: station.homepage != null,
              onTap: () async {
                if (station.homepage != null) {
                  Uri url = Uri.parse(station.homepage!);
                  await launchUrl(url);
                }
              },
              icon: IconFont.home,
              text:
                  // '电台主页'
                  AppLocalizations.of(context).mine_station_page),
          _popMenuItem(
              enabled: true,
              onTap: () {
                context.read<FavoriteCubit>().delFavorite(station);
              },
              icon: IconFont.delete,
              text:
                  //  '删除'
                  AppLocalizations.of(context).mine_station_delete),
          _popMenuItem(
              enabled: true,
              onTap: () {
                if (group != null && group.id != null) {
                  context.read<FavoriteCubit>().clearFavorite(group.id!);
                }
              },
              icon: IconFont.close,
              text:
                  // '清空分组'
                  AppLocalizations.of(context).mine_group_clear),
        ],
        elevation: 8.0);
  }

  PopupMenuItem<Never> _popMenuItem(
      {required bool enabled,
      required VoidCallback onTap,
      required IconData icon,
      required String text}) {
    return PopupMenuItem<Never>(
      mouseCursor: SystemMouseCursors.basic,
      height: 30.0,
      enabled: enabled,
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

  @override
  bool get wantKeepAlive => true;
}
