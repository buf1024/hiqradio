import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/desktop/components/check_list_overlay.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_placeholder.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyFavorite extends StatefulWidget {
  const MyFavorite({super.key});

  @override
  State<MyFavorite> createState() => _MyFavoriteState();
}

class _MyFavoriteState extends State<MyFavorite>
    with AutomaticKeepAliveClientMixin {
  bool isGroupEditing = false;
  TextEditingController groupEditingController = TextEditingController();
  FocusNode groupFocusNode = FocusNode();

  bool isGroupDescEditing = false;
  TextEditingController groupDescEditingController = TextEditingController();
  FocusNode groupDescFocusNode = FocusNode();

  OverlayEntry? overlay;

  bool isExporting = false;
  bool isImporting = false;

  @override
  void initState() {
    super.initState();

    groupFocusNode.addListener(() {
      if (!groupFocusNode.hasFocus) {
        setState(() {
          isGroupEditing = false;
        });
        context.read<AppCubit>().setEditing(false);
      }
    });

    groupDescFocusNode.addListener(() {
      if (!groupDescFocusNode.hasFocus) {
        setState(() {
          isGroupDescEditing = false;
        });
        context.read<AppCubit>().setEditing(false);
      }
    });

    String? groupName = context.read<FavoriteCubit>().getLoadedGroup();
    context.read<FavoriteCubit>().loadFavorite(groupName: groupName);
    context.read<FavoriteCubit>().loadGroups();
  }

  @override
  void dispose() {
    super.dispose();
    groupEditingController.dispose();
    groupFocusNode.dispose();

    groupDescEditingController.dispose();
    groupDescFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildIntro(), Expanded(child: _buildContent())],
      ),
    );
  }

  Widget _buildIntro() {
    FavGroup? group = context.select<FavoriteCubit, FavGroup?>(
      (value) => value.state.group,
    );
    List<FavGroup> groups = context.select<FavoriteCubit, List<FavGroup>>(
      (value) => value.state.groups,
    );
    Station? station = context.select<FavoriteCubit, Station?>((value) {
      for (var station in value.state.stations) {
        if (station.favicon != null && station.favicon!.isNotEmpty) {
          return station;
        }
      }
      return null;
    });
    List<Station> stations = context.select<FavoriteCubit, List<Station>>(
      (value) => value.state.stations,
    );
    return Container(
        height: 145.0,
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            SizedBox(
              height: 145.0,
              width: 145.0,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: station != null &&
                        station.favicon != null &&
                        station.favicon!.isNotEmpty
                    ? CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: station.favicon!,
                        placeholder: (context, url) {
                          return const StationPlaceholder(
                            height: 145.0,
                            width: 145.0,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const StationPlaceholder(
                            height: 145.0,
                            width: 145.0,
                          );
                        },
                      )
                    : const StationPlaceholder(
                        height: 145.0,
                        width: 145.0,
                      ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 28.0,
                      child: Row(
                        children: [
                          InkClick(
                            onTap: () {},
                            child: Container(
                              width: 110.0,
                              alignment: Alignment.centerRight,
                              child: Text(
                                // '分组：',
                                "${AppLocalizations.of(context)!.mine_group}(${AppLocalizations.of(context)!.mine_group_is_def}${(group != null && group.id == 1) ? 'Y' : 'N'}): ",
                              ),
                            ),
                          ),
                          group != null
                              ? (isGroupEditing
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      width: 220.0,
                                      height: 28.0,
                                      child: TextField(
                                        controller: groupEditingController,
                                        focusNode: groupFocusNode,
                                        autocorrect: false,
                                        obscuringCharacter: '*',
                                        cursorWidth: 1.0,
                                        showCursor: true,
                                        cursorColor: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!,
                                        style: const TextStyle(fontSize: 14.0),
                                        decoration: InputDecoration(
                                          hintText:
                                              // '分组名称',
                                              AppLocalizations.of(context)!
                                                  .mine_group_hit,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 6.0),
                                          fillColor:
                                              Colors.grey.withOpacity(0.2),
                                          filled: true,
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.0)),
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.0)),
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                        ),
                                        onSubmitted: (value) {
                                          context
                                              .read<FavoriteCubit>()
                                              .updateGroup(
                                                  value,
                                                  group.desc == null
                                                      ? ''
                                                      : group.desc!);
                                        },
                                        onTap: () {
                                          context
                                              .read<AppCubit>()
                                              .setEditing(true);
                                        },
                                      ),
                                    )
                                  : InkClick(
                                      onTap: () {
                                        setState(() {
                                          groupEditingController.text =
                                              group.name;
                                          isGroupEditing = true;
                                        });
                                        context
                                            .read<AppCubit>()
                                            .setEditing(true);
                                        groupFocusNode.requestFocus();
                                      },
                                      child: Text(
                                        group.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: InkClick(
                              onTapDown: (globalOffset, localOffset) {
                                _onShowDialog(
                                    offset: globalOffset,
                                    groups: groups,
                                    group: group,
                                    width: 40.0,
                                    height: 250.0,
                                    onConfirmed: (isModified, favGroup) {
                                      if (isModified && favGroup != null) {
                                        context
                                            .read<FavoriteCubit>()
                                            .switchGroup(favGroup);
                                      }
                                    },
                                    onDelete: (favGroup) {
                                      context
                                          .read<FavoriteCubit>()
                                          .deleteGroup(favGroup);
                                    },
                                    onNew: () async {
                                      FavGroup g = await context
                                          .read<FavoriteCubit>()
                                          .addNewGroup();
                                      setState(() {
                                        groupEditingController.text = g.name;
                                        isGroupEditing = true;
                                      });
                                      context.read<AppCubit>().setEditing(true);
                                      groupFocusNode.requestFocus();
                                    });
                              },
                              child: Container(
                                height: 20.0,
                                padding: const EdgeInsets.only(
                                    top: 1.0,
                                    bottom: 4.0,
                                    left: 4.0,
                                    right: 4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: const Icon(
                                  Icons.expand_more_outlined,
                                  size: 18.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 28.0,
                      child: Row(
                        children: [
                          Container(
                            width: 110.0,
                            alignment: Alignment.centerRight,
                            child: Text(
                              // '创建时间: ',
                              AppLocalizations.of(context)!.mine_create_time,
                            ),
                          ),
                          Text(
                            group != null
                                ? DateFormat("yyyy-MM-dd HH:mm:ss").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        group.createTime))
                                : '',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 28.0,
                      child: Row(
                        children: [
                          Container(
                            width: 110.0,
                            alignment: Alignment.centerRight,
                            child: Text(
                                // '电台数量: ',
                                AppLocalizations.of(context)!
                                    .mine_station_count),
                          ),
                          Text(
                            '${stations.length}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 28.0,
                      child: Row(
                        children: [
                          Container(
                            width: 110.0,
                            alignment: Alignment.centerRight,
                            child: Text(
                                // '简介: ',
                                AppLocalizations.of(context)!.mine_group_desc),
                          ),
                          group != null
                              ? (isGroupDescEditing
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      width: 320.0,
                                      height: 28.0,
                                      child: TextField(
                                        controller: groupDescEditingController,
                                        focusNode: groupDescFocusNode,
                                        autocorrect: false,
                                        obscuringCharacter: '*',
                                        cursorWidth: 1.0,
                                        showCursor: true,
                                        cursorColor: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!,
                                        style: const TextStyle(fontSize: 14.0),
                                        decoration: InputDecoration(
                                          hintText:
                                              // '分组描述',
                                              AppLocalizations.of(context)!
                                                  .mine_group_desc_hit,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 6.0),
                                          fillColor:
                                              Colors.grey.withOpacity(0.2),
                                          filled: true,
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.0)),
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.0)),
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                        ),
                                        onSubmitted: (value) {
                                          context
                                              .read<FavoriteCubit>()
                                              .updateGroup(group.name, value);
                                        },
                                        onTap: () {
                                          context
                                              .read<AppCubit>()
                                              .setEditing(true);
                                        },
                                      ),
                                    )
                                  : InkClick(
                                      onTap: () {
                                        setState(() {
                                          groupDescEditingController.text =
                                              group.desc ?? '';
                                          isGroupDescEditing = true;
                                        });
                                        context
                                            .read<AppCubit>()
                                            .setEditing(true);
                                        groupDescFocusNode.requestFocus();
                                      },
                                      child: Text(
                                        group.desc ?? '',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                              : Container(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkClick(
                      child: Container(
                        height: 28.0,
                        width: 48.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: isExporting
                            ? Center(
                                child: Container(
                                  height: 15.0,
                                  width: 15.0,
                                  padding: const EdgeInsets.all(2.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.cmm_export,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                ),
                              ),
                      ),
                      onTap: () async {
                        if (isExporting) {
                          return;
                        }
                        setState(() {
                          isExporting = true;
                        });
                        String? selectedDirectory =
                            await FilePicker.platform.getDirectoryPath();

                        if (selectedDirectory != null) {
                          String fileName =
                              'Export-${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}.json';
                          String outFileName =
                              '$selectedDirectory${Platform.pathSeparator}$fileName';

                          String jsStr = await context
                              .read<FavoriteCubit>()
                              .exportFavJson();
                          File output = File(outFileName);
                          if (!await output.exists()) {
                            await output.create(recursive: true);
                          }

                          await output.writeAsString(jsStr);
                          setState(() {
                            isExporting = false;
                          });
                          showToast(
                              '${AppLocalizations.of(context)!.mine_export_msg}  $outFileName',
                              position: const ToastPosition(
                                align: Alignment.bottomCenter,
                              ),
                              duration: const Duration(seconds: 5));
                        } else {
                          setState(() {
                            isExporting = false;
                          });
                        }
                      },
                    ),
                    InkClick(
                      child: Container(
                        height: 28.0,
                        width: 48.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: isImporting
                            ? Center(
                                child: Container(
                                  height: 15.0,
                                  width: 15.0,
                                  padding: const EdgeInsets.all(2.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.cmm_import,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                ),
                              ),
                      ),
                      onTap: () async {
                        if (isImporting) {
                          return;
                        }
                        setState(() {
                          isImporting = true;
                        });
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          File file = File(result.files.single.path!);
                          String jsStr = await file.readAsString();
                          List<dynamic> jsObj = jsonDecode(jsStr);
                          await context
                              .read<FavoriteCubit>()
                              .importFavJson(jsObj);

                          setState(() {
                            isImporting = false;
                          });
                          showToast(
                              AppLocalizations.of(context)!.mine_import_msg,
                              position: const ToastPosition(
                                align: Alignment.bottomCenter,
                              ),
                              duration: const Duration(seconds: 5));
                        } else {
                          setState(() {
                            isImporting = false;
                          });
                        }
                      },
                    ),
                  ],
                )),
          ],
        ));
  }

  Widget _buildContent() {
    return Column(
      children: [
        // _tableFuncs(),
        Expanded(child: _table())
      ],
    );
  }

  Widget _emptyTable() {
    return Center(
      child: Text(
        // '空空如也',
        AppLocalizations.of(context)!.mine_empty,
        style: const TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
  }

  Widget _table() {
    List<Station> stations = context.select<FavoriteCubit, List<Station>>(
      (value) => value.state.stations,
    );
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        dividerThickness: 0,
        bottomMargin: 10,
        sortColumnIndex: 4,
        sortAscending: true,
        sortArrowIcon: Icons.keyboard_arrow_up, // custom arrow
        sortArrowAnimationDuration: const Duration(milliseconds: 500),
        dataRowHeight: 35.0,
        headingRowHeight: 35.0,
        headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.grey.withOpacity(0.1)),
        empty: _emptyTable(),
        columns: [
          const DataColumn2(label: Text(''), fixedWidth: 24.0),
          DataColumn2(
            label: Text(AppLocalizations.of(context)!.cmm_station),
          ),
          DataColumn2(label: Text(AppLocalizations.of(context)!.cmm_tag)),
          DataColumn2(label: Text(AppLocalizations.of(context)!.cmm_language)),
          DataColumn2(label: Text(AppLocalizations.of(context)!.cmm_district)),
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.cmm_format),
              fixedWidth: 55.0),
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.cmm_bitrate),
              fixedWidth: 55.0),
        ],
        rows: stations.asMap().entries.map(
          (entry) {
            int index = entry.key;
            Station station = entry.value;
            bool isSelected = playingStation != null &&
                station.stationuuid == playingStation.stationuuid;
            return DataRow2(
              selected: isSelected,
              color: index.isEven
                  ? MaterialStateProperty.all(Colors.grey.withOpacity(0.05))
                  : null,
              onSecondaryTapDown: (details) async {
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
              onDoubleTap: () {
                if (isPlaying && playingStation != null) {
                  context.read<RecentlyCubit>().updateRecently(playingStation);
                }
                context.read<AppCubit>().play(station);
                context.read<RecentlyCubit>().addRecently(station);
              },
              cells: [
                DataCell(
                  Row(
                    children: [
                      !isSelected || !isPlaying
                          ? Icon(
                              IconFont.volume,
                              size: 18.0,
                              color: Colors.red.withOpacity(0.0),
                            )
                          : InkClick(
                              onTap: () {},
                              child: Icon(
                                IconFont.volume,
                                size: 18.0,
                                color: Colors.red.withOpacity(0.8),
                              ),
                            ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        width: 30.0,
                        height: 30.0,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(2.0)),
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl:
                                station.favicon != null ? station.favicon! : '',
                            placeholder: (context, url) {
                              return const StationPlaceholder(
                                height: 30.0,
                                width: 30.0,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return const StationPlaceholder(
                                height: 30.0,
                                width: 30.0,
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          station.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    station.tags != null ? station.tags! : '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    ResManager.instance.getLanguageText(station.language),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    ResManager.instance
                        .getLocationText(station.countrycode, station.state),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    station.codec != null && station.codec!.length <= 4
                        ? station.codec!
                        : '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    station.bitrate != null
                        ? (station.bitrate! != 0 ? '${station.bitrate}' : '')
                        : '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }

  void _popOverlay() {
    if (overlay != null) {
      overlay!.remove();
      overlay = null;
    }
  }

  void _onShowDialog({
    required Offset offset,
    required List<FavGroup> groups,
    FavGroup? group,
    required double width,
    required double height,
    Function(bool, FavGroup?)? onConfirmed,
    Function(FavGroup)? onDelete,
    VoidCallback? onNew,
  }) async {
    // 为了弹出框事标题能够移动，只能猥琐发育
    overlay = OverlayEntry(
        opaque: false,
        builder: (context) {
          // 猥琐发育
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 0),
                //padding: const EdgeInsets.only(top: kTitleBarHeight),
                child: ModalBarrier(
                  onDismiss: () {
                    _popOverlay();
                  },
                ),
              ),
              Positioned(
                top: offset.dy,
                left: offset.dx,
                child: Material(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Dialog(
                        alignment: Alignment.center,
                        elevation: 2.0,
                        insetPadding: const EdgeInsets.all(0),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Container(
                          width: width,
                          height: height,
                          constraints: BoxConstraints(
                              maxWidth: width, maxHeight: height),
                          // padding: const EdgeInsets.all(8.0),
                          child: PopupContent(
                              groups: groups,
                              group: group,
                              onConfirmed: (isModified, favGroup) {
                                onConfirmed?.call(isModified, favGroup);
                                _popOverlay();
                              },
                              onDelete: (favGroup) {
                                onDelete?.call(favGroup);
                                _popOverlay();
                              },
                              onNew: () {
                                onNew?.call();
                                _popOverlay();
                              }),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        });
    Overlay.of(context).insert(overlay!);
  }

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
                  AppLocalizations.of(context)!.cmm_stop
                  :
                  // '播放'
                  AppLocalizations.of(context)!.cmm_play),
          _popMenuItem(
              enabled: true,
              onTap: () {
                _popOverlay();
                Size size = MediaQuery.of(context).size;
                overlay = createCheckSelectedListOverlay(
                    text:
                        // '选择新分组',
                        AppLocalizations.of(context)!.mine_select_new_group,
                    data: data,
                    selected: selected,
                    width: size.width * 0.15,
                    height: size.height * 0.6,
                    onDismiss: () {
                      _popOverlay();
                    },
                    isMulSelected: true,
                    onTap: (isModified, newSelected) {
                      _popOverlay();
                      if (isModified) {
                        if (group != null) {
                          context
                              .read<FavoriteCubit>()
                              .changeGroup(station, group.name, newSelected);
                        }
                      }
                    });
                Overlay.of(context).insert(overlay!);
              },
              icon: const Icon(
                IconFont.edit,
                size: 14.0,
              ),
              text:
                  // '修改分组'
                  AppLocalizations.of(context)!.mine_modify_group),
          _popMenuItem(
              enabled: station.homepage != null,
              onTap: () async {
                if (station.homepage != null) {
                  Uri url = Uri.parse(station.homepage!);
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(
                IconFont.home,
                size: 14.0,
              ),
              text:
                  // '电台主页'
                  AppLocalizations.of(context)!.mine_station_page),
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
                  AppLocalizations.of(context)!.mine_station_delete),
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
                  AppLocalizations.of(context)!.mine_group_clear),
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
                AppLocalizations.of(context)!.mine_select_group,
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
                                      .where((element) => element.id == 1)
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
                                AppLocalizations.of(context)!
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
                              AppLocalizations.of(context)!.cmm_cancel,
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
                      favGroup.id != 1
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
