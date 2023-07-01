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
          padding: const EdgeInsets.all(5.0),
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
                  showTableContextMenu(
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

  // Widget _table() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
  //     child: DataTable2(
  //       columns: [
  //         const DataColumn2(label: Text(''), fixedWidth: 24.0),
  //         DataColumn2(
  //           label: Text(AppLocalizations.of(context).cmm_station),
  //         ),
  //         DataColumn2(label: Text(AppLocalizations.of(context).cmm_tag)),
  //         DataColumn2(label: Text(AppLocalizations.of(context).cmm_language)),
  //         DataColumn2(label: Text(AppLocalizations.of(context).cmm_district)),
  //         DataColumn2(
  //             label: Text(AppLocalizations.of(context).cmm_format),
  //             fixedWidth: 55.0),
  //         DataColumn2(
  //             label: Text(AppLocalizations.of(context).cmm_bitrate),
  //             fixedWidth: 55.0),
  //       ],
  //       rows: stations.asMap().entries.map(
  //         (entry) {
  //           int index = entry.key;
  //           Station station = entry.value;
  //           bool isSelected = playingStation != null &&
  //               station.stationuuid == playingStation.stationuuid;
  //           return DataRow2(
  //             selected: isSelected,
  //             color: index.isEven
  //                 ? MaterialStateProperty.all(Colors.grey.withOpacity(0.05))
  //                 : null,
  //             onSecondaryTapDown: (details) async {
  //               List<String> data = groups.map((e) => e.name).toList();
  //               List<String> sSelected = await context
  //                   .read<FavoriteCubit>()
  //                   .loadStationGroup(station);
  //               showTableContextMenu(
  //                   details.globalPosition,
  //                   station,
  //                   playingStation != null &&
  //                       playingStation.urlResolved == station.urlResolved &&
  //                       isPlaying,
  //                   group,
  //                   data,
  //                   sSelected);
  //             },
  //             onDoubleTap: () {
  //               if (isPlaying && playingStation != null) {
  //                 context.read<RecentlyCubit>().updateRecently(playingStation);
  //               }
  //               context.read<AppCubit>().play(station);
  //               context.read<RecentlyCubit>().addRecently(station);
  //             },
  //             cells: [
  //               DataCell(
  //                 Row(
  //                   children: [
  //                     !isSelected || !isPlaying
  //                         ? Icon(
  //                             IconFont.volume,
  //                             size: 18.0,
  //                             color: Colors.red.withOpacity(0.0),
  //                           )
  //                         : InkClick(
  //                             onTap: () {},
  //                             child: Icon(
  //                               IconFont.volume,
  //                               size: 18.0,
  //                               color: Colors.red.withOpacity(0.8),
  //                             ),
  //                           ),
  //                   ],
  //                 ),
  //               ),
  //               DataCell(
  //                 Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(6.0),
  //                       width: 30.0,
  //                       height: 30.0,
  //                       child: ClipRRect(
  //                         borderRadius:
  //                             const BorderRadius.all(Radius.circular(2.0)),
  //                         child: CachedNetworkImage(
  //                           fit: BoxFit.fill,
  //                           imageUrl:
  //                               station.favicon != null ? station.favicon! : '',
  //                           placeholder: (context, url) {
  //                             return const StationPlaceholder(
  //                               height: 30.0,
  //                               width: 30.0,
  //                             );
  //                           },
  //                           errorWidget: (context, url, error) {
  //                             return const StationPlaceholder(
  //                               height: 30.0,
  //                               width: 30.0,
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: Text(
  //                         station.name,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               DataCell(
  //                 Text(
  //                   station.tags != null ? station.tags! : '',
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               DataCell(
  //                 Text(
  //                   ResManager.instance.getLanguageText(station.language),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               DataCell(
  //                 Text(
  //                   ResManager.instance
  //                       .getLocationText(station.countrycode, station.state),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               DataCell(
  //                 Text(
  //                   station.codec != null && station.codec!.length <= 4
  //                       ? station.codec!
  //                       : '',
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               DataCell(
  //                 Text(
  //                   station.bitrate != null
  //                       ? (station.bitrate! != 0 ? '${station.bitrate}' : '')
  //                       : '',
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ).toList(),
  //     ),
  //   );
  // }

  // void _popOverlay() {
  //   if (overlay != null) {
  //     overlay!.remove();
  //     overlay = null;
  //   }
  // }

  // void _onShowDialog({
  //   required Offset offset,
  //   required List<FavGroup> groups,
  //   FavGroup? group,
  //   required double width,
  //   required double height,
  //   Function(bool, FavGroup?)? onConfirmed,
  //   Function(FavGroup)? onDelete,
  //   VoidCallback? onNew,
  // }) async {
  //   // 为了弹出框事标题能够移动，只能猥琐发育
  //   overlay = OverlayEntry(
  //       opaque: false,
  //       builder: (context) {
  //         // 猥琐发育
  //         return Stack(
  //           alignment: Alignment.center,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.only(top: kTitleBarHeight),
  //               child: ModalBarrier(
  //                 onDismiss: () {
  //                   _popOverlay();
  //                 },
  //               ),
  //             ),
  //             Positioned(
  //               top: offset.dy,
  //               left: offset.dx,
  //               child: Material(
  //                 child: StatefulBuilder(
  //                   builder: (context, setState) {
  //                     return Dialog(
  //                       alignment: Alignment.center,
  //                       elevation: 2.0,
  //                       insetPadding: const EdgeInsets.all(0),
  //                       shape: const RoundedRectangleBorder(
  //                           borderRadius:
  //                               BorderRadius.all(Radius.circular(10.0))),
  //                       child: Container(
  //                         width: width,
  //                         height: height,
  //                         constraints: BoxConstraints(
  //                             maxWidth: width, maxHeight: height),
  //                         // padding: const EdgeInsets.all(8.0),
  //                         child: PopupContent(
  //                             groups: groups,
  //                             group: group,
  //                             onConfirmed: (isModified, favGroup) {
  //                               onConfirmed?.call(isModified, favGroup);
  //                               _popOverlay();
  //                             },
  //                             onDelete: (favGroup) {
  //                               onDelete?.call(favGroup);
  //                             },
  //                             onNew: () {
  //                               onNew?.call();
  //                               _popOverlay();
  //                             }),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  //   Overlay.of(context).insert(overlay!);
  // }

  void showTableContextMenu(Offset offset, Station station, bool isPlaying,
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
              icon: Icon(
                isPlaying ? IconFont.stop : IconFont.play,
                size: 14.0,
              ),
              text: isPlaying
                  ?
                  // '停止'
                  AppLocalizations.of(context).cmm_stop
                  :
                  // '播放'
                  AppLocalizations.of(context).cmm_play),
          // _popMenuItem(
          //     enabled: true,
          //     onTap: () {
          //       _popOverlay();
          //       Size size = MediaQuery.of(context).size;
          //       overlay = createCheckSelectedListOverlay(
          //           text:
          //               // '选择新分组',
          //               AppLocalizations.of(context).mine_select_new_group,
          //           data: data,
          //           selected: selected,
          //           width: size.width * 0.15,
          //           height: size.height * 0.6,
          //           onDismiss: () {
          //             _popOverlay();
          //           },
          //           isMulSelected: true,
          //           onTap: (isModified, newSelected) {
          //             _popOverlay();
          //             if (isModified) {
          //               if (group != null) {
          //                 context
          //                     .read<FavoriteCubit>()
          //                     .changeGroup(station, group.name, newSelected);
          //               }
          //             }
          //           });
          //       Overlay.of(context).insert(overlay!);
          //     },
          //     icon: const Icon(
          //       IconFont.edit,
          //       size: 14.0,
          //     ),
          //     text:
          //         // '修改分组'
          //         AppLocalizations.of(context).mine_modify_group),
          _popMenuItem(
              enabled: station.homepage != null,
              onTap: () async {
                if (station.homepage != null) {
                  Uri url = Uri.parse(station.homepage!);
                  await launchUrl(url);
                }
              },
              icon: const Icon(
                IconFont.home,
                size: 14.0,
              ),
              text:
                  // '电台主页'
                  AppLocalizations.of(context).mine_station_page),
          _popMenuItem(
              enabled: true,
              onTap: () {
                context.read<FavoriteCubit>().delFavorite(station);
              },
              icon: const Icon(
                IconFont.delete,
                size: 14.0,
              ),
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
              icon: const Icon(
                IconFont.close,
                size: 14.0,
              ),
              text:
                  // '清空分组'
                  AppLocalizations.of(context).mine_group_clear),
        ],
        elevation: 8.0);
  }

  PopupMenuItem<Never> _popMenuItem(
      {required bool enabled,
      required VoidCallback onTap,
      required Widget icon,
      required String text}) {
    return PopupMenuItem<Never>(
      mouseCursor: SystemMouseCursors.basic,
      height: 20.0,
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
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14.0),
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

class PopupContent extends StatefulWidget {
  final List<FavGroup> groups;
  final Function(bool, FavGroup?) onConfirmed;
  final Function(FavGroup) onDelete;
  final VoidCallback onNew;
  final FavGroup? group;
  const PopupContent(
      {super.key,
      required this.groups,
      required this.onConfirmed,
      required this.group,
      required this.onDelete,
      required this.onNew});

  @override
  State<PopupContent> createState() => _PopupContentState();
}

class _PopupContentState extends State<PopupContent> {
  FavGroup? group;
  List<FavGroup> groups = [];
  bool isModified = false;

  FavGroup? groupTryingDel;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    group = widget.group;
    groups = widget.groups;
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  void didUpdateWidget(covariant PopupContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) {
      group = widget.group;
    }
    if (oldWidget.groups != widget.groups) {
      groups = widget.groups;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          widget.onConfirmed.call(isModified, group);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                // '选择分组: ',
                AppLocalizations.of(context).mine_select_group,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (BuildContext context, int index) {
                  FavGroup favGroup = groups[index];
                  if (groupTryingDel != null &&
                      groupTryingDel!.name == favGroup.name) {
                    return Row(
                      children: [
                        Expanded(
                          child: InkClick(
                            onTap: () {
                              widget.onDelete(groupTryingDel!);
                              setState(() {
                                groups.remove(groupTryingDel!);
                                if (group!.name == groupTryingDel!.name) {
                                  FavGroup g = groups
                                      .where((element) => element.isDef == 1)
                                      .first;
                                  group = g;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                // '确定删除: ${favGroup.name} ',
                                AppLocalizations.of(context)
                                    .mine_delete_group(favGroup.name),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        InkClick(
                          onTap: () {
                            setState(
                              () {
                                groupTryingDel = null;
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.8),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              // '取消',
                              AppLocalizations.of(context).cmm_cancel,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: InkClick(
                          onTap: () {
                            if (group == null || favGroup.name != group!.name) {
                              group = favGroup;
                              isModified = true;
                              setState(() {});
                            }
                            widget.onConfirmed(isModified, group);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 5.0),
                            child: Row(
                              children: [
                                group != null && favGroup.name == group!.name
                                    ? Container(
                                        width: 30.0,
                                        padding: const EdgeInsets.all(2.0),
                                        child: const Icon(
                                          IconFont.check,
                                          size: 11.0,
                                        ),
                                      )
                                    : const SizedBox(
                                        width: 30.0,
                                      ),
                                Expanded(
                                  child: Text(
                                    favGroup.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      favGroup.isDef == 0
                          ? InkClick(
                              onTap: () {
                                setState(() {
                                  groupTryingDel = favGroup;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                height: 25.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.8),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4.0))),
                                child: const Center(
                                  child: Icon(
                                    IconFont.delete,
                                    size: 15.0,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              height: 25.0,
                              width: 30.0,
                            )
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                const Spacer(),
                InkClick(
                  onTap: () => widget.onNew(),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50.0))),
                    child: Icon(
                      IconFont.add,
                      size: 12.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                  ),
                ),
                const Spacer()
              ],
            )
          ],
        ),
      ),
    );
  }
}
