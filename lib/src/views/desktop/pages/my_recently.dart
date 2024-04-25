import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
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
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyRecently extends StatefulWidget {
  const MyRecently({super.key});

  @override
  State<MyRecently> createState() => _MyRecentlyState();
}

class _MyRecentlyState extends State<MyRecently>
    with AutomaticKeepAliveClientMixin {
  TextEditingController pageSizeEditController = TextEditingController();
  FocusNode pageSizeFocusNode = FocusNode();
  bool isPageSizeEditing = false;

  TextEditingController pageEditController = TextEditingController();
  FocusNode pageFocusNode = FocusNode();
  bool isPageEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<RecentlyCubit>().loadRecently();

    pageSizeFocusNode.addListener(() {
      if (!pageSizeFocusNode.hasFocus) {
        if (isPageSizeEditing) {
          int? pageSize = int.tryParse(pageSizeEditController.text);
          if (pageSize != null) {
            context.read<RecentlyCubit>().changePageSize(pageSize);
          }
        }
        setState(() {
          isPageSizeEditing = !isPageSizeEditing;
        });
        context.read<AppCubit>().setEditing(false);
      }
    });
    pageFocusNode.addListener(() {
      if (!pageFocusNode.hasFocus) {
        if (isPageEditing) {
          int? page = int.tryParse(pageEditController.text);
          if (page != null) {
            context.read<RecentlyCubit>().changePage(page);
          }
        }

        setState(() {
          isPageEditing = !isPageEditing;
        });
        context.read<AppCubit>().setEditing(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _tableFuncs(),
          Expanded(child: _table()),
          _buildJumpInfo()
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

  Widget _buildJumpInfo() {
    int totalPage =
        context.select<RecentlyCubit, int>((value) => value.state.totalPage);

    // int totalSize =
    //     context.select<RecentlyCubit, int>((value) => value.state.totalSize);

    int pageSize =
        context.select<RecentlyCubit, int>((value) => value.state.pageSize);
    pageSizeEditController.text = '$pageSize';

    int page = context.select<RecentlyCubit, int>((value) => value.state.page);
    pageEditController.text = '$page';

    // if (totalSize <= pageSize) {
    //   return Container();
    // }

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
      child: Row(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // '每页 ',
              AppLocalizations.of(context)!.stat_station_per_page,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          _buildEditing(isPageSizeEditing, pageSizeEditController,
              pageSizeFocusNode, '$pageSize', () {
            isPageSizeEditing = true;
            setState(() {});
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // '个 共 ',
              AppLocalizations.of(context)!.stat_station_total_page,
              style: const TextStyle(fontSize: 13.0),
            ),
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
              '$totalPage',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  fontSize: 13.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // ' 页 当前第 ',
              AppLocalizations.of(context)!.stat_station_cur_page,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          _buildEditing(
              isPageEditing, pageEditController, pageFocusNode, '$page', () {
            isPageEditing = true;
            setState(() {});
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // ' 页',
              AppLocalizations.of(context)!.stat_station_cur_page_no,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  // '前一页',
                  AppLocalizations.of(context)!.stat_station_pre_page,
                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ),
              onTap: () {
                context.read<RecentlyCubit>().changePage(page - 1);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  // '后一页',
                  AppLocalizations.of(context)!.stat_station_next_page,

                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ),
              onTap: () {
                context.read<RecentlyCubit>().changePage(page + 1);
              },
            ),
          ),
          const SizedBox(
            width: 6.0,
          )
        ],
      ),
    );
  }

  Widget _buildEditing(bool test, TextEditingController controller,
      FocusNode focusNode, String text, VoidCallback onEditSwitch) {
    return test
        ? SizedBox(
            // padding: const EdgeInsets.symmetric(horizontal: 8.0),
            width: 40.0,
            height: 18.0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              autocorrect: false,
              obscuringCharacter: '*',
              cursorWidth: 1.0,
              showCursor: true,
              cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
              style: const TextStyle(fontSize: 13.0),
              decoration: InputDecoration(
                // hintText: '10~100',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                    borderRadius: BorderRadius.circular(5.0)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              onTap: () {
                context.read<AppCubit>().setEditing(true);
              },
            ),
          )
        : InkClick(
            onTap: () {
              onEditSwitch.call();
              context.read<AppCubit>().setEditing(true);
              pageSizeFocusNode.requestFocus();
            },
            child: Container(
              width: 40,
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
          );
  }

  Widget _table() {
    List<Pair<Station, Recently>> recentlys =
        context.select<RecentlyCubit, List<Pair<Station, Recently>>>(
            (value) => value.state.pagedRecently);

    Station? playingStation = context.select<AppCubit, Station?>(
      (value) => value.state.playingStation,
    );
    bool isPlaying = context.select<AppCubit, bool>(
      (value) => value.state.isPlaying,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        dividerThickness: 0, // this one will be ignored if [border] is set above
        bottomMargin: 10,
        // minWidth: 900,
        // sortColumnIndex: 4,
        sortAscending: true,
        sortArrowIcon: Icons.keyboard_arrow_up, // custom arrow
        sortArrowAnimationDuration: const Duration(milliseconds: 500),
        dataRowHeight: 35.0,
        headingRowHeight: 35.0,
        headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.grey.withOpacity(0.1)),
        columns: [
          DataColumn2(label: Text(AppLocalizations.of(context)!.cmm_station)),
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.cmm_start_time),
              fixedWidth: 170.0),
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.cmm_end_time),
              fixedWidth: 170.0),
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.cmm_last_time),
              fixedWidth: 70.0),
        ],
        empty: _empty(),

        rows: recentlys.asMap().entries.map(
          (e) {
            int index = e.key;
            Station station = e.value.p1;
            Recently recently = e.value.p2;

            bool isSelected = playingStation != null &&
                playingStation.urlResolved == station.urlResolved;

            String sDuration = '';
            if (recently.endTime != null) {
              var duration = DateTime.fromMillisecondsSinceEpoch(
                      recently.endTime!)
                  .difference(
                      DateTime.fromMillisecondsSinceEpoch(recently.startTime));
              sDuration =
                  "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
            }

            return DataRow2(
              selected: isSelected,
              color: index.isEven
                  ? MaterialStateProperty.all(Colors.grey.withOpacity(0.05))
                  : null,
              onSecondaryTapDown: (details) {
                showContextMenu(details.globalPosition);
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
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        width: 30.0,
                        height: 30.0,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(2.0)),
                          child: station.favicon != null &&
                                  station.favicon!.isNotEmpty
                              ? CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl: station.favicon!,
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
                                )
                              : const StationPlaceholder(
                                  height: 30.0,
                                  width: 30.0,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          station.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    DateFormat("yyyy-MM-dd HH:mm:ss").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            recently.startTime)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    recently.endTime != null
                        ? DateFormat("yyyy-MM-dd HH:mm:ss").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                recently.endTime!))
                        : '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    sDuration,
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
      height: 20.0,
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
                size: 14.0,
              ),
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
