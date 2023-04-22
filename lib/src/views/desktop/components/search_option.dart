import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/views/desktop/utils/comm_obj.dart';
import 'package:window_manager/window_manager.dart';

class SearchOption extends StatefulWidget {
  final Function(String?, String?, String?, List<String>?)? optionChanged;
  const SearchOption({super.key, this.optionChanged});

  @override
  State<SearchOption> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SearchOption> {
  String country = '';
  String state = '';
  String language = '';
  List<String> tags = [];

  late List<CountInfo<String>> allTags;
  late List<CountInfo<String>> allLanguages;
  late List<CountInfo<String>> allStates;
  late List<CountInfo<String>> allCountries;

  TextEditingController tagAddController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    allTags = [
      CountInfo(value: '#英语', count: 112),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
    ];
    allLanguages = [
      CountInfo(value: '#英语', count: 112),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
    ];
    allStates = [
      CountInfo(value: '#英语', count: 112),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
    ];
    allCountries = [
      CountInfo(value: '#英语', count: 112),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
      CountInfo(value: '#语文', count: 12),
      CountInfo(value: '年代', count: 912),
      CountInfo(value: '摇滚', count: 912),
      CountInfo(value: '飞跃', count: 91),
      CountInfo(value: '睡眠', count: 9),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    tagAddController.dispose();
    languageController.dispose();
    countryController.dispose();
    stateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildCountry(), _buildLanguage(), _buildTagList()],
    );
  }

  Widget _buildCountry() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '区域: ',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ),
        InkClick(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              country.isEmpty ? '国家/地区' : country,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          onTap: () async {
            Size size = await windowManager.getSize();
            _onShowDialog(countryController, allCountries,
                (isModified, selected) {
              if (isModified) {
                country = selected[0];
                setState(() {});
              }
            }, country.isEmpty ? [] : [country], false, size.width * 0.3,
                size.height * 0.7);
          },
        ),
        const SizedBox(
          width: 8.0,
        ),
        InkClick(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              state.isEmpty ? '省/州' : state,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          onTap: () async {
            Size size = await windowManager.getSize();
            _onShowDialog(stateController, allStates,
                (isModified, selected) {
              if (isModified) {
                state = selected[0];
                setState(() {});
              }
            }, state.isEmpty ? [] : [state], false, size.width * 0.3,
                size.height * 0.7);
          },
        ),
      ],
    );
  }

  Widget _buildLanguage() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '语言: ',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ),
        InkClick(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              language.isEmpty ? '所有' : language,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          onTap: () async {
            Size size = await windowManager.getSize();
            _onShowDialog(languageController, allLanguages,
                (isModified, selected) {
              if (isModified) {
                language = selected[0];
                setState(() {});
              }
            }, language.isEmpty ? [] : [language], false, size.width * 0.3,
                size.height * 0.7);
          },
        ),
      ],
    );
  }

  Widget _buildTagList() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '标签: ',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ),
        InkClick(
          child: Container(
            height: 20.0,
            width: 30.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: const Icon(
              IconFont.add,
              size: 10.0,
            ),
          ),
          onTap: () async {
            Size size = await windowManager.getSize();
            _onShowDialog(tagAddController, allTags, (isModified, selected) {
              if (isModified) {
                tags = selected;
                setState(() {});
              }
            }, tags, true, size.width * 0.3, size.height * 0.7);
            // _onShowDialog(size.width * 0.3, size.height * 0.7);
          },
        ),
        const SizedBox(
          width: 10.0,
        ),
        tags.isNotEmpty
            ? Expanded(
                child: SizedBox(
                  height: 22,
                  child: ListView.builder(
                    itemCount: tags.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      String tag = tags[index];
                      return Row(
                        children: [
                          InkClick(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                tags.remove(tag);
                              });
                            },
                          ),
                          const SizedBox(
                            width: 8.0,
                          )
                        ],
                      );
                    },
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void _onShowDialog(
      TextEditingController editingController,
      List<CountInfo<String>> infos,
      Function(bool, List<String>) onConfirmed,
      List<String> selected,
      bool isMulSelected,
      double width,
      double height) async {
    bool? isModified = await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.0),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            alignment: Alignment.center,
            elevation: 2.0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Container(
              width: width,
              height: height,
              padding: const EdgeInsets.all(8.0),
              child: DialogContent(
                editController: editingController,
                infos: infos,
                onConfirmed: (isModified, selected) {
                  onConfirmed.call(isModified, selected);
                  Navigator.of(context).pop(isModified);
                },
                selected: selected,
                isMulSelected: isMulSelected,
              ),
            ),
          );
        });
      },
    );
    if (isModified != null && isModified) {
      setState(() {});
    }
  }
}

class DialogContent extends StatefulWidget {
  final TextEditingController editController;
  final List<CountInfo> infos;
  final Function(bool, List<String>) onConfirmed;
  final List<String> selected;
  final bool isMulSelected;
  const DialogContent(
      {super.key,
      required this.editController,
      required this.infos,
      required this.onConfirmed,
      required this.selected,
      required this.isMulSelected});

  @override
  State<DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends _OptionDialogState<DialogContent> {
  List<String> selected = [];
  bool isModified = false;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
    filterText = widget.editController.text;
  }

  @override
  void didUpdateWidget(covariant DialogContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      selected = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CountInfo> filteredInfo = filterText.isNotEmpty
        ? widget.infos
            .where((element) => element.value.contains(filterText))
            .toList()
        : widget.infos;

    return Column(
      children: <Widget>[
        searchField(widget.editController, (value) {
          setState(
            () {
              filterText = value;
            },
          );
        }),
        Expanded(
          child: ListView.builder(
            itemCount: filteredInfo.length,
            itemBuilder: (BuildContext context, int index) {
              CountInfo info = filteredInfo[index];
              return InkClick(
                onTap: () {
                  if (widget.isMulSelected) {
                    if (selected.contains(info.value)) {
                      selected.remove(info.value);
                    } else {
                      selected.add(info.value);
                    }
                  } else {
                    if (selected.isEmpty) {
                      selected = [info.value];
                    } else {
                      if (info.value == selected[0]) {
                        selected = [];
                      } else {
                        selected = [info.value];
                      }
                    }
                  }

                  setState(() {
                    isModified = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 2.0),
                  child: Row(
                    children: [
                      selected.contains(info.value)
                          ? Container(
                              width: 20.0,
                              padding: const EdgeInsets.all(2.0),
                              child: const Icon(
                                IconFont.check,
                                size: 11.0,
                              ),
                            )
                          : const SizedBox(
                              width: 20.0,
                            ),
                      Text(
                        info.value,
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.withOpacity(0.8)),
                      ),
                      const Spacer(),
                      Text(
                        '${info.count}',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.withOpacity(0.8)),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ButtonBar(
          buttonPadding: const EdgeInsets.all(4.0),
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                setState(() {
                  selected = [];
                });
              },
              child: Text(
                '清空',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 13.0),
              ),
            ),
            MaterialButton(
              // color: Colors.red,
              onPressed: () {
                widget.onConfirmed.call(isModified, selected);
              },
              child: Text('确定',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13.0,
                  )),
            ),
          ],
        )
      ],
    );
  }
}

abstract class _OptionDialogState<T extends StatefulWidget> extends State<T> {
  String filterText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget searchField(
      TextEditingController controller, ValueChanged valueChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
      height: 26.0,
      // width: 220.0,
      child: TextField(
        controller: controller,
        autofocus: true,
        autocorrect: false,
        obscuringCharacter: '*',
        cursorWidth: 1.0,
        // showCursor: focusNode.hasFocus,
        cursorColor: Colors.grey.withOpacity(0.8),
        style: TextStyle(fontSize: 12.0, color: Colors.grey.withOpacity(0.8)),
        decoration: InputDecoration(
          // hintText: '过滤',
          prefixIcon: Icon(Icons.search_outlined,
              size: 18.0, color: Colors.grey.withOpacity(0.8)),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.text = '';
                    valueChanged.call('');
                  },
                  child: Icon(Icons.close_outlined,
                      size: 16.0, color: Colors.grey.withOpacity(0.8)),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
          fillColor: Colors.grey.withOpacity(0.2),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
            // borderRadius: BorderRadius.circular(50.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
            // borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        onChanged: (value) {
          valueChanged.call(value);
        },
      ),
    );
  }
}
