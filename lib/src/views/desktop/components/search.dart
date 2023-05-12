import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/components/station_info.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool isShowRecent = true;
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

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  bool get isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Column(
        children: [
          _buildRecent(),
          Expanded(
            child: _buildResult(),
          )
        ],
      ),
    );
  }

  Widget _buildRecent() {
    List<String> recentSearch = context.select<SearchCubit, List<String>>(
      (value) => isShowRecent ? value.state.recentSearch : const [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '最近搜索',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: InkClick(
                onTap: () {
                  setState(() {
                    isShowRecent = !isShowRecent;
                  });
                },
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 80.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(
                    !isShowRecent
                        ? Icons.expand_more_outlined
                        : Icons.expand_less_outlined,
                    size: 16.0,
                  ),
                ),
              ),
            ),
            InkClick(
              child: Text(
                '清空',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.red.withOpacity(0.8),
                ),
              ),
              onTap: () {
                context.read<SearchCubit>().clearRecently();
              },
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Wrap(
            children: recentSearch.map((elem) {
              Map<String, dynamic> map = jsonDecode(elem);
              String text = '${map["search"]}';

              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: InkClick(
                  onTap: () {
                    context
                        .read<SearchCubit>()
                        .searchConditionFromRecently(map);
                  },
                  child: Container(
                    height: 20.0,
                    constraints: const BoxConstraints(maxWidth: 80.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).textTheme.bodyMedium!.color!,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Text(
                '搜索结果： 共 ',
                style: TextStyle(fontSize: 13.0),
              ),
              Container(
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '$totalSize',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.0),
                ),
              ),
              const Text(
                ' 个',
                style: TextStyle(fontSize: 13.0),
              ),
            ],
          ),
        ),
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
                      return ListTile(
                        contentPadding: const EdgeInsets.all(4.0),
                        splashColor: Colors.black.withOpacity(0),
                        title: StationInfo(
                          onClicked: () {},
                          width: 200,
                          height: 54,
                          station: station,
                        ),
                        onTap: () {
                          if (isPlaying) {
                            context.read<AppCubit>().stop();
                            if (playingStation != null) {
                              context
                                  .read<RecentlyCubit>()
                                  .updateRecently(playingStation);
                            }
                          } else {
                            context.read<AppCubit>().play(station);
                            context.read<RecentlyCubit>().addRecently(station);
                          }
                        },
                        mouseCursor: SystemMouseCursors.click,
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
}
