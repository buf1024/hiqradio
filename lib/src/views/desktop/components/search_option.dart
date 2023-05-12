import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:window_manager/window_manager.dart';

class CountInfo<T> {
  String value;
  int count;
  T? data;
  CountInfo({required this.value, required this.count, this.data});
}

class SearchOption extends StatefulWidget {
  final Function(String, String, String, List<String>) onOptionChanged;
  final List<String> selectedTags;
  final String selectedLanguage;
  final String selectedCountry;
  final String selectedState;
  const SearchOption({
    super.key,
    required this.onOptionChanged,
    required this.selectedTags,
    required this.selectedLanguage,
    required this.selectedCountry,
    required this.selectedState,
  });

  @override
  State<SearchOption> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SearchOption> {
  TextEditingController tagAddController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  OverlayEntry? optOverlay;

  late String selectedLanguage;
  late String selectedCountry;
  late String selectedState;
  late List<String> selectedTags;

  String displaySelectedLanguage = '';
  String displaySelectedCountry = '';
  String displaySelectedState = '';

  @override
  void initState() {
    super.initState();

    selectedLanguage = widget.selectedLanguage;
    selectedCountry = widget.selectedCountry;
    selectedState = widget.selectedState;
    selectedTags = widget.selectedTags;

    _getDisplay();
  }

  @override
  void didUpdateWidget(covariant SearchOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool isUpdate = false;
    if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      selectedLanguage = widget.selectedLanguage;
      isUpdate = true;
    }
    if (oldWidget.selectedCountry != widget.selectedCountry) {
      selectedCountry = widget.selectedCountry;
      isUpdate = true;
    }
    if (oldWidget.selectedState != widget.selectedState) {
      selectedState = widget.selectedState;
      isUpdate = true;
    }
    if (oldWidget.selectedTags != widget.selectedTags) {
      selectedTags = widget.selectedTags;
      isUpdate = true;
    }
    if (isUpdate) {
      _getDisplay();
    }
  }

  @override
  void dispose() {
    super.dispose();
    tagAddController.dispose();
    languageController.dispose();
    countryController.dispose();
    stateController.dispose();
  }

  void _getDisplay() {
    displaySelectedLanguage =
        selectedLanguage.isNotEmpty ? _getLangDisplay(selectedLanguage) : '';

    displaySelectedCountry =
        selectedCountry.isNotEmpty ? _getCountryDisplay(selectedCountry) : '';

    displaySelectedState =
        selectedState.isNotEmpty ? _getStateDisplay(selectedState) : '';
  }

  void _onOptionChanged() {
    widget.onOptionChanged
        .call(selectedCountry, selectedState, selectedLanguage, selectedTags);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildCountry(), _buildLanguage(), _buildTagList()],
    );
  }

  String _getCountryDisplay(String countryCode) {
    Map<String, CountryInfo> map = ResManager.instance.countryMap;
    CountryInfo countryInfo = map[countryCode]!;
    return '${countryInfo.flag} ${countryInfo.nameNative}/${countryInfo.name}';
  }

  String _getStateDisplay(String state) {
    return state;
  }

  Widget _buildCountry() {
    bool isCountryLoading = context
        .select<AppCubit, bool>((value) => value.state.isCountriesLoading);

    List<Country> countries = context
        .select<AppCubit, List<Country>>((value) => value.state.countries);

    bool isStateLoading =
        context.select<AppCubit, bool>((value) => value.state.isStateLoading);

    List<CountryState> states =
        context.select<AppCubit, List<CountryState>>((value) {
      if (value.state.states.isEmpty ||
          selectedCountry.isEmpty ||
          value.state.states[selectedCountry] == null) {
        return const [];
      } else {
        return value.state.states[selectedCountry]!;
      }
    });

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: const Text(
            '区域: ',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
        InkClick(
          child: Container(
            height: 28.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Text(
                  displaySelectedCountry.isEmpty
                      ? '国家/地区'
                      : displaySelectedCountry,
                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
                if (isCountryLoading)
                  Container(
                    height: 20.0,
                    width: 20.0,
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                  )
              ],
            ),
          ),
          onTap: () async {
            if (countries.isEmpty) {
              countries = await context.read<AppCubit>().loadCountries();
            }
            if (countries.isNotEmpty) {
              List<CountInfo<Country>> allCountries = countries.map(
                (e) {
                  String display = _getCountryDisplay(e.countrycode!);
                  CountInfo<Country> countInfo =
                      CountInfo(value: display, count: e.stationcount, data: e);
                  return countInfo;
                },
              ).toList();

              Size size = await windowManager.getSize();
              _onShowDialog(
                  editingController: countryController,
                  infos: allCountries,
                  onConfirmed: (isModified, selected, selectedInfo) {
                    if (isModified) {
                      String tmp = selected.isEmpty ? '' : selected[0];
                      if (tmp != displaySelectedCountry) {
                        displaySelectedCountry = tmp;

                        selectedCountry = '';
                        if (displaySelectedCountry.isNotEmpty) {
                          Country country = selectedInfo[0].data!;
                          selectedCountry = country.countrycode!;
                        }

                        _onOptionChanged();
                      }
                    }
                  },
                  selected: displaySelectedCountry.isEmpty
                      ? []
                      : [displaySelectedCountry],
                  isMulSelected: false,
                  width: size.width * 0.3,
                  height: size.height * 0.7);
            }
          },
        ),
        const SizedBox(
          width: 8.0,
        ),
        InkClick(
          child: Container(
            height: 28.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Text(
                  displaySelectedState.isEmpty ? '省/州' : displaySelectedState,
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                if (isStateLoading)
                  Container(
                    height: 20.0,
                    width: 20.0,
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                  )
              ],
            ),
          ),
          onTap: () async {
            if (states.isEmpty && selectedCountry.isNotEmpty) {
              states =
                  await context.read<AppCubit>().loadStates(selectedCountry);
            }
            if (states.isNotEmpty) {
              List<CountInfo<CountryState>> allStates = states.map(
                (e) {
                  String display = _getStateDisplay(e.state!);
                  CountInfo<CountryState> countInfo =
                      CountInfo(value: display, count: e.stationcount, data: e);
                  return countInfo;
                },
              ).toList();
              Size size = await windowManager.getSize();
              _onShowDialog(
                  editingController: stateController,
                  infos: allStates,
                  onConfirmed: (isModified, selected, selectedInfo) {
                    if (isModified) {
                      String tmp = selected.isEmpty ? '' : selected[0];
                      if (tmp != displaySelectedState) {
                        displaySelectedState = tmp;

                        selectedState = '';
                        if (displaySelectedState.isNotEmpty) {
                          CountryState countryState = selectedInfo[0].data!;
                          selectedState = countryState.state!;
                        }

                        _onOptionChanged();
                      }
                    }
                  },
                  selected: displaySelectedState.isEmpty
                      ? []
                      : [displaySelectedState],
                  isMulSelected: false,
                  width: size.width * 0.3,
                  height: size.height * 0.7);
            }
          },
        ),
      ],
    );
  }

  String _getLangDisplay(String langCode) {
    Map<String, LanguageInfo> map = ResManager.instance.langMap;
    LanguageInfo langInfo = map[langCode]!;
    return '${langInfo.nameNative}/${langInfo.name}';
  }

  Widget _buildLanguage() {
    bool isLangLoading =
        context.select<AppCubit, bool>((value) => value.state.isLangLoading);

    List<Language> languages = context
        .select<AppCubit, List<Language>>((value) => value.state.languages);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: const Text(
            '语言: ',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
        InkClick(
          child: Container(
            height: 28.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Text(
                  displaySelectedLanguage.isEmpty
                      ? '所有'
                      : displaySelectedLanguage,
                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
                if (isLangLoading)
                  Container(
                    height: 20.0,
                    width: 20.0,
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                  )
              ],
            ),
          ),
          onTap: () async {
            if (languages.isEmpty) {
              languages = await context.read<AppCubit>().loadLanguage();
            }
            if (languages.isNotEmpty) {
              List<CountInfo<Language>> allLanguages = languages.map(
                (e) {
                  String display = _getLangDisplay(e.languagecode!);
                  CountInfo<Language> countInfo =
                      CountInfo(value: display, count: e.stationcount, data: e);
                  return countInfo;
                },
              ).toList();

              Size size = await windowManager.getSize();
              _onShowDialog(
                  editingController: languageController,
                  infos: allLanguages,
                  onConfirmed: (isModified, selected, selectedInfo) {
                    if (isModified) {
                      String tmp = selected.isEmpty ? '' : selected[0];
                      if (tmp != displaySelectedLanguage) {
                        displaySelectedLanguage = tmp;

                        selectedLanguage = '';
                        if (displaySelectedLanguage.isNotEmpty) {
                          Language language = selectedInfo[0].data!;
                          selectedLanguage = language.languagecode!;
                        }
                        _onOptionChanged();
                      }
                    }
                  },
                  selected: displaySelectedLanguage.isEmpty
                      ? []
                      : [displaySelectedLanguage],
                  isMulSelected: false,
                  width: size.width * 0.3,
                  height: size.height * 0.7);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTagList() {
    bool isTagLoading =
        context.select<AppCubit, bool>((value) => value.state.isTagLoading);

    List<Tag> tags =
        context.select<AppCubit, List<Tag>>((value) => value.state.tags);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: const Text(
            '标签: ',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
        InkClick(
          child: Container(
              height: 28.0,
              width: !isTagLoading ? 30.0 : 48.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  const Icon(
                    IconFont.add,
                    size: 10.0,
                  ),
                  if (isTagLoading)
                    Container(
                      height: 20.0,
                      width: 20.0,
                      padding: const EdgeInsets.all(4.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        color: Theme.of(context).textTheme.bodyMedium!.color!,
                      ),
                    ),
                ],
              )),
          onTap: () async {
            if (tags.isEmpty) {
              tags = await context.read<AppCubit>().loadTags();
            }
            if (tags.isNotEmpty) {
              List<CountInfo<Tag>> allTags = tags.map(
                (e) {
                  CountInfo<Tag> countInfo =
                      CountInfo(value: e.tag!, count: e.stationcount, data: e);
                  return countInfo;
                },
              ).toList();

              Size size = await windowManager.getSize();
              _onShowDialog(
                  editingController: tagAddController,
                  infos: allTags,
                  onConfirmed: (isModified, selected, selectedInfo) {
                    if (isModified) {
                      selectedTags = selected;
                      _onOptionChanged();
                    }
                  },
                  selected: selectedTags,
                  isMulSelected: true,
                  width: size.width * 0.3,
                  height: size.height * 0.7);
            }
          },
        ),
        const SizedBox(
          width: 10.0,
        ),
        selectedTags.isNotEmpty
            ? Expanded(
                child: SizedBox(
                  height: 28.0,
                  child: ListView.builder(
                    itemCount: selectedTags.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      String tag = selectedTags[index];
                      return Row(
                        children: [
                          InkClick(
                            child: Container(
                              height: 28.0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!,
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                            onTap: () {
                              selectedTags.remove(tag);
                              _onOptionChanged();
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

  void _popOverlay() {
    if (optOverlay != null) {
      optOverlay!.remove();
      optOverlay = null;
    }
  }

  void _onShowDialog(
      {required TextEditingController editingController,
      required List<CountInfo> infos,
      required Function(bool, List<String>, List<CountInfo>) onConfirmed,
      required List<String> selected,
      required bool isMulSelected,
      required double width,
      required double height}) async {
    // 为了弹出框事标题能够移动，只能猥琐发育
    optOverlay = OverlayEntry(
        opaque: false,
        builder: (context) {
          // 猥琐发育
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(top: kTitleBarHeight),
                child: ModalBarrier(
                  onDismiss: () {
                    _popOverlay();
                  },
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
                        child: SizedBox(
                          width: width,
                          height: height,
                          // padding: const EdgeInsets.all(8.0),
                          child: DialogContent(
                            editController: editingController,
                            infos: infos,
                            onConfirmed: (isModified, selected, selectedInfo) {
                              onConfirmed.call(
                                  isModified, selected, selectedInfo);
                              // Navigator.of(context).pop(isModified);
                              _popOverlay();
                            },
                            selected: selected,
                            isMulSelected: isMulSelected,
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
    Overlay.of(context).insert(optOverlay!);
  }
}

class DialogContent extends StatefulWidget {
  final TextEditingController editController;
  final List<CountInfo> infos;
  final Function(bool, List<String>, List<CountInfo>) onConfirmed;
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
  List<CountInfo> selectedInfo = [];
  List<CountInfo> infos = [];
  bool isModified = false;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selected);
    infos = widget.infos;
    filterText = widget.editController.text;
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  void didUpdateWidget(covariant DialogContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      selected = widget.selected;
    }
  }

  @override
  void editFocusLost() {
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    List<CountInfo> filteredInfo = filterText.isNotEmpty
        ? infos
            .where((element) =>
                element.value.toLowerCase().contains(filterText.toLowerCase()))
            .toList()
        : infos;

    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          widget.onConfirmed.call(isModified, selected, selectedInfo);
        }
      },
      child: Column(
        children: <Widget>[
          searchField(
            widget.editController,
            (value) {
              setState(
                () {
                  filterText = value;
                },
              );
            },
          ),
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
                        selectedInfo.remove(info);
                      } else {
                        selected.add(info.value);
                        selectedInfo.add(info);
                      }
                    } else {
                      if (selected.isEmpty) {
                        selected = [info.value];
                        selectedInfo = [info];
                      } else {
                        if (info.value == selected[0]) {
                          selected = [];
                          selectedInfo = [];
                        } else {
                          selected = [info.value];
                          selectedInfo = [info];
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
                        Expanded(
                          child: Text(
                            info.value,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!),
                          ),
                        ),
                        Text(
                          '${info.count}',
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
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
                    if (selected.isNotEmpty || selectedInfo.isNotEmpty) {
                      isModified = true;
                    }
                    selected = [];
                    selectedInfo = [];
                  });
                },
                child: const Text(
                  '清空',
                  style: TextStyle(fontSize: 13.0),
                ),
              ),
              MaterialButton(
                // color: Colors.red,
                onPressed: () {
                  widget.onConfirmed.call(isModified, selected, selectedInfo);
                },
                child: const Text('确定',
                    style: TextStyle(
                      fontSize: 13.0,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

abstract class _OptionDialogState<T extends StatefulWidget> extends State<T> {
  String filterText = '';
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editFocusNode.requestFocus();

    _editFocusNode.addListener(() {
      if (!_editFocusNode.hasFocus) {
        editFocusLost();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _editFocusNode.dispose();
  }

  void editFocusLost() {}

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget searchField(
      TextEditingController controller, ValueChanged valueChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      height: 30.0,
      // width: 220.0,
      child: TextField(
          controller: controller,
          focusNode: _editFocusNode,
          autocorrect: false,
          obscuringCharacter: '*',
          cursorWidth: 1.0,
          cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
          style: const TextStyle(fontSize: 13.0),
          decoration: InputDecoration(
            // hintText: '过滤',
            prefixIcon: Icon(Icons.search_outlined,
                size: 18.0,
                color: Theme.of(context).textTheme.bodyMedium!.color!),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller.text = '';
                      valueChanged.call('');
                    },
                    child: Icon(Icons.close_outlined,
                        size: 16.0,
                        color: Theme.of(context).textTheme.bodyMedium!.color!),
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
          }),
    );
  }
}
