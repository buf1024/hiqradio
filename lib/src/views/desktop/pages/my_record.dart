import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/record_cubit.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/pair.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/components/station_placeholder.dart';
import 'package:intl/intl.dart';

class MyRecord extends StatefulWidget {
  const MyRecord({super.key});

  @override
  State<MyRecord> createState() => _MyRecordState();
}

class _MyRecordState extends State<MyRecord>
    with AutomaticKeepAliveClientMixin {
  int selectedId = -1;
  @override
  void initState() {
    super.initState();
    context.read<RecordCubit>().loadRecord();
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
          Expanded(child: _table())
        ],
      ),
    );
  }

  Widget _empty() {
    bool isLoading =
        context.select<RecordCubit, bool>((value) => value.state.isLoading);
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
    return const Center(
      child: Text(
        '暂无录音记录',
        style: TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
  }

  Widget _table() {
    List<Pair<Station, Record>> records =
        context.select<RecordCubit, List<Pair<Station, Record>>>(
            (value) => value.state.records);
    Record? playingRecord = context.select<AppCubit, Record?>(
      (value) => value.state.playingRecord,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        dividerThickness:
            1, // this one will be ignored if [border] is set above
        bottomMargin: 10,
        // minWidth: 900,
        sortColumnIndex: 4,
        sortAscending: true,
        sortArrowIcon: Icons.keyboard_arrow_up, // custom arrow
        sortArrowAnimationDuration: const Duration(milliseconds: 500),
        dataRowHeight: 35.0,
        headingRowHeight: 35.0,
        headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.grey.withOpacity(0.1)),
        columns: const [
          DataColumn2(label: Text(''), fixedWidth: 24.0),
          DataColumn2(label: Text('电台')),
          DataColumn2(label: Text('开始时间'), fixedWidth: 170.0),
          DataColumn2(label: Text('结束时间'), fixedWidth: 170.0),
          DataColumn2(label: Text('时长(估)'), fixedWidth: 80.0),
          DataColumn2(label: Text('格式'), fixedWidth: 45.0),
        ],
        empty: _empty(),
        rows: records.asMap().entries.map(
          (e) {
            int index = e.key;
            Station station = e.value.p1;
            Record record = e.value.p2;

            String sDuration = '';
            if (record.endTime != null) {
              var duration = DateTime.fromMillisecondsSinceEpoch(
                      record.endTime!)
                  .difference(
                      DateTime.fromMillisecondsSinceEpoch(record.startTime));
              sDuration =
                  "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
            }
            return DataRow2(
              selected: selectedId == record.id,
              color: index.isEven
                  ? MaterialStateProperty.all(Colors.grey.withOpacity(0.05))
                  : null,
              onTap: () {},
              onSecondaryTapDown: ((details) {
                showContextMenu(details.globalPosition, record);
              }),
              onDoubleTap: () {
                setState(() {
                  selectedId = record.id!;
                });
                if (playingRecord != null && playingRecord.id == record.id) {
                  context.read<AppCubit>().stopPlayRecord();
                } else {
                  context.read<AppCubit>().playRecord(record);
                }
              },
              cells: [
                DataCell(
                  Row(
                    children: [
                      playingRecord != null && playingRecord.id == record.id
                          ? Icon(
                              IconFont.volume,
                              size: 18.0,
                              color: Colors.red.withOpacity(0.8),
                            )
                          : InkClick(
                              onTap: () {},
                              child: Icon(
                                IconFont.volume,
                                size: 18.0,
                                color: Colors.red.withOpacity(0.0),
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
                      Text(
                        station.name,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    DateFormat("yyyy-MM-dd HH:mm:ss").format(
                        DateTime.fromMillisecondsSinceEpoch(record.startTime)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    record.endTime != null
                        ? DateFormat("yyyy-MM-dd HH:mm:ss").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                record.endTime!))
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
                DataCell(
                  Text(
                    station.codec != null && station.codec!.length <= 4
                        ? station.codec!
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

  void showContextMenu(Offset offset, Record record) {
    showMenu(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        position: RelativeRect.fromLTRB(
            offset.dx, offset.dy + 5.0, offset.dx, offset.dy),
        items: [
          _popMenuItem(() {
            context.read<RecordCubit>().delRecord(record.id!);
          }, IconFont.delete, '删除录音'),
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