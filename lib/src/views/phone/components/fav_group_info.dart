import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_placeholder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class FavGroupInfo extends StatefulWidget {
  const FavGroupInfo({super.key});

  @override
  State<FavGroupInfo> createState() => _FavGroupInfoState();
}

class _FavGroupInfoState extends State<FavGroupInfo> {
  bool isGroupEditing = false;
  TextEditingController groupEditingController = TextEditingController();
  FocusNode groupFocusNode = FocusNode();

  bool isGroupDescEditing = false;
  TextEditingController groupDescEditingController = TextEditingController();
  FocusNode groupDescFocusNode = FocusNode();

  bool isTryingDel = false;

  @override
  void initState() {
    super.initState();

    groupFocusNode.addListener(() {
      if (!groupFocusNode.hasFocus) {
        setState(() {
          isGroupEditing = false;
        });
      }
    });

    groupDescFocusNode.addListener(() {
      if (!groupDescFocusNode.hasFocus) {
        setState(() {
          isGroupDescEditing = false;
        });
      }
    });
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
    FavGroup? group = context.select<FavoriteCubit, FavGroup?>(
      (value) => value.state.group,
    );
    List<FavGroup> groups = context.select<FavoriteCubit, List<FavGroup>>(
      (value) => value.state.groups,
    );
    // Station? station = context.select<FavoriteCubit, Station?>((value) {
    //   for (var station in value.state.stations) {
    //     if (station.favicon != null && station.favicon!.isNotEmpty) {
    //       return station;
    //     }
    //   }
    //   return null;
    // });
    List<Station> stations = context.select<FavoriteCubit, List<Station>>(
      (value) => value.state.stations,
    );

    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    Size size = MediaQuery.of(context).size;

    return Container(
      height: 430,
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              DropdownButton(
                  value: group!.name,
                  underline: Container(),
                  borderRadius: BorderRadius.circular(8.0),
                  items: [
                    ...groups
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.name,
                            // alignment: Alignment.center,
                            child: Text(
                              e.name,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    DropdownMenuItem<String>(
                      value: '#**+**#2',
                      alignment: Alignment.center,
                      enabled: false,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: '#**+**#1',
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color!,
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
                  ],
                  onChanged: (value) async {
                    if (value != null && !value.startsWith('#**')) {
                      FavGroup favGroup =
                          groups.where((e) => e.name == value).first;
                      context.read<FavoriteCubit>().switchGroup(favGroup);
                    } else {
                      FavGroup favGroup =
                          await context.read<FavoriteCubit>().addNewGroup();
                      context.read<FavoriteCubit>().switchGroup(favGroup);
                    }
                  }),
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32.0,
                    child: Row(
                      children: [
                        InkClick(
                          onTap: () {},
                          child: Container(
                            width: 90.0,
                            alignment: Alignment.centerRight,
                            child: Text(
                              // '分组：',
                              AppLocalizations.of(context).mine_group,
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: isGroupEditing
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  width: 220.0,
                                  height: 32.0,
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
                                    style: const TextStyle(fontSize: 20.0),
                                    decoration: InputDecoration(
                                      hintText:
                                          // '分组名称',
                                          AppLocalizations.of(context)
                                              .mine_group_hit,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 6.0),
                                      fillColor: Colors.grey.withOpacity(0.2),
                                      filled: true,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.0)),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.0)),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ),
                                    onSubmitted: (value) {
                                      context.read<FavoriteCubit>().updateGroup(
                                          value,
                                          group.desc == null
                                              ? ''
                                              : group.desc!);
                                    },
                                    onTap: () {},
                                  ),
                                )
                              : InkClick(
                                  onTap: () {
                                    setState(() {
                                      groupEditingController.text = group.name;
                                      isGroupEditing = true;
                                    });
                                    groupFocusNode.requestFocus();
                                  },
                                  child: Text(
                                    group.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 20.0),
                                  ),
                                ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32.0,
                    child: Row(
                      children: [
                        Container(
                          width: 85.0,
                          alignment: Alignment.centerRight,
                          child: Text(
                            AppLocalizations.of(context).mine_group_is_def,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            group.id == 1 ? ' Y' : ' N',
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32.0,
                    child: Row(
                      children: [
                        Container(
                          width: 85.0,
                          alignment: Alignment.centerRight,
                          child: Text(
                            // '创建时间: ',
                            AppLocalizations.of(context).mine_create_time,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' ${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.fromMillisecondsSinceEpoch(group.createTime))}',
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32.0,
                    child: Row(
                      children: [
                        Container(
                          width: 85.0,
                          alignment: Alignment.centerRight,
                          child: Text(
                            // '电台数量: ',
                            AppLocalizations.of(context).mine_station_count,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' ${stations.length}',
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32.0,
                    child: Row(
                      children: [
                        Container(
                          width: 90.0,
                          alignment: Alignment.centerRight,
                          child: Text(
                            // '简介: ',
                            AppLocalizations.of(context).mine_group_desc,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Expanded(
                          child: isGroupDescEditing
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  width: 320.0,
                                  height: 32.0,
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
                                    style: const TextStyle(fontSize: 20.0),
                                    decoration: InputDecoration(
                                      hintText:
                                          // '分组描述',
                                          AppLocalizations.of(context)
                                              .mine_group_desc_hit,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 6.0),
                                      fillColor: Colors.grey.withOpacity(0.2),
                                      filled: true,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.0)),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(0.0)),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ),
                                    onSubmitted: (value) {
                                      context
                                          .read<FavoriteCubit>()
                                          .updateGroup(group.name, value);
                                    },
                                    onTap: () {},
                                  ),
                                )
                              : InkClick(
                                  onTap: () {
                                    setState(() {
                                      groupDescEditingController.text =
                                          group.desc ?? '';
                                      isGroupDescEditing = true;
                                    });
                                    groupDescFocusNode.requestFocus();
                                  },
                                  child: Text(
                                    group.desc ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 20.0),
                                  ),
                                ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: size.width,
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stations.length,
              itemBuilder: (BuildContext context, int index) {
                Station station = stations[index];
                return Container(
                  height: 130.0,
                  width: 130.0,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  child: InkClick(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      child:
                          station.favicon != null && station.favicon!.isNotEmpty
                              ? CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl: station.favicon!,
                                  placeholder: (context, url) {
                                    return const StationPlaceholder(
                                      height: 130.0,
                                      width: 130.0,
                                    );
                                  },
                                  errorWidget: (context, url, error) {
                                    return const StationPlaceholder(
                                      height: 130.0,
                                      width: 130.0,
                                    );
                                  },
                                )
                              : const StationPlaceholder(
                                  height: 130.0,
                                  width: 130.0,
                                ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (isPlaying) {
                        context.read<AppCubit>().stop();
                        if (playingStation != null) {
                          context
                              .read<RecentlyCubit>()
                              .updateRecently(playingStation);
                        }
                      } else {
                        if (playingStation != null) {
                          context.read<AppCubit>().play(playingStation);
                          context
                              .read<RecentlyCubit>()
                              .addRecently(playingStation);
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            height: 60.0,
            padding: const EdgeInsets.only(bottom: 10.0),
            child: isTryingDel
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkClick(
                        onTap: () {
                          context.read<FavoriteCubit>().deleteGroup(group);
                          setState(() {
                            isTryingDel = false;
                          });
                        },
                        child: Container(
                          height: 60.0,
                          width: size.width * 0.4,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            // '确定删除: ${favGroup.name} ',
                            AppLocalizations.of(context)
                                .mine_delete_group(group.name),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      InkClick(
                        onTap: () {
                          setState(
                            () {
                              isTryingDel = false;
                            },
                          );
                        },
                        child: Container(
                          height: 60.0,
                          width: size.width * 0.4,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4.0),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            // '取消',
                            AppLocalizations.of(context).cmm_cancel,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : InkClick(
                    onTap: () {
                      if (group.id != 1) {
                        setState(() {
                          isTryingDel = true;
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      // height: 25.0,
                      width: size.width,
                      decoration: BoxDecoration(
                          color: group.id != 1
                              ? Colors.red.withOpacity(0.8)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0))),
                      child: const Center(
                        child: Icon(
                          IconFont.delete,
                          size: 25.0,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
