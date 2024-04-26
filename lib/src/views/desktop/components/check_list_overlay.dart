import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';

OverlayEntry createCheckSelectedListOverlay(
    {required String text,
    required List<String> data,
    required List<String> selected,
    required double width,
    required double height,
    required bool isMulSelected,
    Function(bool, List<String>)? onTap,
    VoidCallback? onDismiss}) {
  // 为了弹出框事标题能够移动，只能猥琐发育
  return OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 0),
              // padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => onDismiss?.call(),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.height -
                          height -
                          kTitleBarHeight) /
                      2 +
                  kTitleBarHeight,
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
                        constraints:
                            BoxConstraints(maxWidth: width, maxHeight: height),
                        // padding: const EdgeInsets.all(8.0),
                        child: CheckSelectedList(
                          text: text,
                          data: data,
                          selected: selected,
                          isMulSelected: isMulSelected,
                          onTap: (isModified, newSelected) =>
                              onTap?.call(isModified, newSelected),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      });
}

class CheckSelectedList extends StatefulWidget {
  final String text;
  final List<String> data;
  final Function(bool, List<String>) onTap;
  final List<String> selected;
  final bool isMulSelected;
  const CheckSelectedList(
      {super.key,
      required this.data,
      required this.onTap,
      required this.selected,
      required this.text,
      required this.isMulSelected});

  @override
  State<CheckSelectedList> createState() => _CheckSelectedListState();
}

class _CheckSelectedListState extends State<CheckSelectedList> {
  List<String> selected = [];
  List<String> data = [];
  bool isModified = false;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
    data = widget.data;
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  void didUpdateWidget(covariant CheckSelectedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      selected = widget.selected;
    }
    if (oldWidget.data != widget.data) {
      data = widget.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          widget.onTap.call(isModified, selected);
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
                widget.text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  String text = data[index];

                  return InkClick(
                    onTap: () {
                      setState(() {
                        if (selected.contains(text)) {
                          selected.remove(text);
                        } else {
                          selected.add(text);
                        }
                        isModified = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 5.0),
                      child: Row(
                        children: [
                          selected.contains(text)
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
                              text,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                const Spacer(),
                InkClick(
                  onTap: () => widget.onTap.call(isModified, selected),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    child: const Text(
                      '确定',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
