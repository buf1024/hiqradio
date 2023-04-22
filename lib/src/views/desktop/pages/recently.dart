import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';


class Recently extends StatefulWidget {
  const Recently({super.key});

  @override
  State<Recently> createState() => _RecentlyState();
}

class _RecentlyState extends State<Recently>
    with AutomaticKeepAliveClientMixin {
  TextEditingController searchEditController = TextEditingController();
  FocusNode searchEditNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    searchEditController.dispose();
    searchEditNode.dispose();
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

  Widget _tableFuncs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      height: 28.0,
      width: 200.0,
      child: TextField(
        controller: searchEditController,
        focusNode: searchEditNode,
        autofocus: true,
        autocorrect: false,
        obscuringCharacter: '*',
        cursorWidth: 1.0,
        showCursor: searchEditNode.hasFocus,
        cursorColor: Colors.grey.withOpacity(0.8),
        style: const TextStyle(fontSize: 14.0),
        decoration: InputDecoration(
          hintText: '搜索',
          prefixIcon: Icon(Icons.search_outlined,
              size: 18.0, color: Colors.grey.withOpacity(0.8)),
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
        onChanged: (value) {},
        onTap: () {},
      ),
    );
  }

  Widget _table() {
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
          DataColumn2(label: Text('开始时间')),
          DataColumn2(label: Text('结束时间')),
          DataColumn2(label: Text('时长')),
        ],
        rows: [
          ...List.generate(100, (v) => v).map(
            (e) {
              bool isSelected = e == 1;
              return DataRow2(
                selected: isSelected,
                color: e.isEven
                    ? MaterialStateProperty.all(Colors.grey.withOpacity(0.05))
                    : null,
                    onSecondaryTapDown: ((details) {
                  showContextMenu(details.globalPosition);
                }),
                cells: [
                  DataCell(
                    Row(
                      children: [
                        !isSelected
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
                                  "https://pic.qtfm.cn/2012/0814/20120814015923282.jpg",
                              placeholder: (context, url) {
                                return Image.asset('assets/images/logo.png');
                              },
                              errorWidget: (context, url, error) {
                                return Image.asset('assets/images/logo.png');
                              },
                            ),
                          ),
                        ),
                        Text('珠江经济台')
                      ],
                    ),
                  ),
                  DataCell(Text('2023/04/02 10:10:10')),
                  DataCell(Text('2023/04/02 10:10:10')),
                  DataCell(Text('7s')),
                ],
              );
            },
          ).toList()
        ],
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
            offset.dx, offset.dy + 5.0, offset.dx, offset.dy ),
        items: [
          _popMenuItem(() {}, IconFont.search, '搜索'),
          _popMenuItem(() {}, IconFont.play, '播放/暂停'),
          _popMenuItem(() {}, IconFont.home, '电台主页'),
          _popMenuItem(() {}, IconFont.delete, '删除'),
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
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14.0),
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
