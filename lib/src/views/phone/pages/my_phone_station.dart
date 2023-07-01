import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:hiqradio/src/views/phone/playing_page.dart';

class MyPhoneStation extends StatefulWidget {
  const MyPhoneStation({super.key});

  @override
  State<MyPhoneStation> createState() => _MyPhoneStationState();
}

class _MyPhoneStationState extends State<MyPhoneStation>
    with AutomaticKeepAliveClientMixin {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (isBottom) {
        context.read<SearchCubit>().fetchMore();
      }
    });
  }

  bool get isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
          child: _buildResult(),
        )),
        // _playingStation()
      ],
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

  Widget _buildResult() {
    int totalSize = context
        .select<SearchCubit, int>((value) => value.state.stations.length);
    bool isSearching =
        context.select<SearchCubit, bool>((value) => value.state.isSearching);

    int size = context.select<SearchCubit, int>((value) => value.state.size);

    List<Station> stations = context
        .select<SearchCubit, List<Station>>((value) => value.state.stations);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    Size winSize = MediaQuery.of(context).size;
    return Column(
      children: [
        isSearching
            ? Container(
                padding: const EdgeInsets.only(top: 45.0),
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              )
            : Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      Station station = stations[index];
                      bool isStationPlaying = isPlaying &&
                          playingStation!.urlResolved == station.urlResolved;

                      return Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            InkClick(
                              child: StationInfo(
                                onClicked: () {
                                  _jumpPlayingPage(
                                      isPlaying, playingStation, station);
                                },
                                width: winSize.width - 68,
                                height: 60,
                                station: station,
                              ),
                              onTap: () {
                                _jumpPlayingPage(
                                    isPlaying, playingStation, station);
                              },
                            ),
                            InkClick(
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!,
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
                                            width:
                                                !isStationPlaying ? 4.0 : 3.0,
                                          ),
                                          Icon(
                                            !isStationPlaying
                                                ? IconFont.play
                                                : IconFont.stop,
                                            size: 12.0,
                                            color: Colors.white,
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
                                            color:
                                                Colors.white.withOpacity(0.2),
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
                                    if (playingStation.urlResolved !=
                                        station.urlResolved) {
                                      context.read<AppCubit>().play(station);
                                      context
                                          .read<RecentlyCubit>()
                                          .addRecently(station);
                                    }
                                  }
                                } else {
                                  context.read<AppCubit>().play(station);
                                  context
                                      .read<RecentlyCubit>()
                                      .addRecently(station);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: size >= totalSize ? size : size + 1,
                    controller: scrollController,
                  ),
                ),
              )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
