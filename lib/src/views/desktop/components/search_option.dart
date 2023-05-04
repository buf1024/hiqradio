import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/search_opt_cubit.dart';
import 'package:hiqradio/src/blocs/search_opt_state.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:window_manager/window_manager.dart';

class CountInfo<T> {
  String value;
  int count;
  T? data;
  CountInfo({required this.value, required this.count, this.data});
}

class SearchOption extends StatefulWidget {
  final Function(String?, String?, String?, List<String>?)? optionChanged;
  const SearchOption({super.key, this.optionChanged});

  @override
  State<SearchOption> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SearchOption> {
  TextEditingController tagAddController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  String _getCountryDisplay(String countryCode) {
    Map<String, CountryInfo> map = ResManager.instance.countryMap;
    CountryInfo countryInfo = map[countryCode]!;
    return '${countryInfo.flag} ${countryInfo.nameNative}/${countryInfo.name}';
  }

  String _getStateDisplay(String state) {
    return state;
  }

  Widget _buildCountry() {
    bool isCountryLoading = context.select<SearchOptCubit, bool>(
        (value) => value.state.isCountriesLoading);
    String selectedCountry = context
        .select<SearchOptCubit, String>((value) => value.state.selectedCountry);

    if (selectedCountry.isNotEmpty) {
      selectedCountry = _getCountryDisplay(selectedCountry);
    }
    List<Country> countries = context.select<SearchOptCubit, List<Country>>(
        (value) => value.state.countries);

    bool isStateLoading = context
        .select<SearchOptCubit, bool>((value) => value.state.isStateLoading);
    String selectedState = context
        .select<SearchOptCubit, String>((value) => value.state.selectedState);

    if (selectedState.isNotEmpty) {
      selectedState = _getStateDisplay(selectedState);
    }
    List<CountryState> states =
        context.select<SearchOptCubit, List<CountryState>>((value) {
      if (value.state.states.isEmpty ||
          value.state.selectedCountry.isEmpty ||
          value.state.states[value.state.selectedCountry] == null) {
        return const [];
      } else {
        return value.state.states[value.state.selectedCountry]!;
      }
    });

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
            height: 28.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Text(
                  selectedCountry.isEmpty ? '国家/地区' : selectedCountry,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (isCountryLoading)
                  Container(
                    height: 20.0,
                    width: 20.0,
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  )
              ],
            ),
          ),
          onTap: () async {
            if (countries.isEmpty) {
              countries = await context.read<SearchOptCubit>().loadCountries();
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
                      if (tmp != selectedCountry) {
                        selectedCountry = tmp;
                        String countryCode = '';
                        if (selectedCountry.isNotEmpty) {
                          Country country = selectedInfo[0].data!;
                          countryCode = country.countrycode!;
                        }
                        context
                            .read<SearchOptCubit>()
                            .selectCountry(countryCode);
                      }
                    }
                  },
                  selected: selectedCountry.isEmpty ? [] : [selectedCountry],
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
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Text(
                  selectedState.isEmpty ? '省/州' : selectedState,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (isStateLoading)
                  Container(
                    height: 20.0,
                    width: 20.0,
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  )
              ],
            ),
          ),
          onTap: () async {
            if (states.isEmpty && selectedCountry.isNotEmpty) {
              states = await context.read<SearchOptCubit>().loadStates();
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
                      if (tmp != selectedState) {
                        selectedState = tmp;
                        String theState = '';
                        if (selectedState.isNotEmpty) {
                          CountryState countryState = selectedInfo[0].data!;
                          theState = countryState.state!;
                        }
                        context.read<SearchOptCubit>().selectState(theState);
                      }
                    }
                  },
                  selected: selectedState.isEmpty ? [] : [selectedState],
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
    bool isLoading = context
        .select<SearchOptCubit, bool>((value) => value.state.isLangLoading);
    String selectedLanguage = context.select<SearchOptCubit, String>(
        (value) => value.state.selectedLanguage);

    if (selectedLanguage.isNotEmpty) {
      selectedLanguage = _getLangDisplay(selectedLanguage);
    }
    List<Language> languages = context.select<SearchOptCubit, List<Language>>(
        (value) => value.state.languages);

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
            height: 28.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Text(
                  selectedLanguage.isEmpty ? '所有' : selectedLanguage,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (isLoading)
                  Container(
                    height: 20.0,
                    width: 20.0,
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  )
              ],
            ),
          ),
          onTap: () async {
            if (languages.isEmpty) {
              languages = await context.read<SearchOptCubit>().loadLanguage();
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
                      if (tmp != selectedLanguage) {
                        selectedLanguage = tmp;
                        String langCode = '';
                        if (selectedLanguage.isNotEmpty) {
                          Language language = selectedInfo[0].data!;
                          langCode = language.languagecode!;
                        }
                        context.read<SearchOptCubit>().selectLanguage(langCode);
                      }
                    }
                  },
                  selected: selectedLanguage.isEmpty ? [] : [selectedLanguage],
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
    bool isTagLoading = context
        .select<SearchOptCubit, bool>((value) => value.state.isTagLoading);
    List<String> selectedTags = context.select<SearchOptCubit, List<String>>(
        (value) => value.state.selectedTags);

    List<Tag> tags =
        context.select<SearchOptCubit, List<Tag>>((value) => value.state.tags);

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
              height: 28.0,
              width: 30.0,
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
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
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                ],
              )),
          onTap: () async {
            if (tags.isEmpty) {
              tags = await context.read<SearchOptCubit>().loadTags();
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
                      context.read<SearchOptCubit>().selectTag(selectedTags);
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
                  height: 22,
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
                                selectedTags.remove(tag);
                                context
                                    .read<SearchOptCubit>()
                                    .selectTag(selectedTags);
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
      {required TextEditingController editingController,
      required List<CountInfo> infos,
      required Function(bool, List<String>, List<CountInfo>) onConfirmed,
      required List<String> selected,
      required bool isMulSelected,
      required double width,
      required double height}) async {
    await showDialog(
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
                onConfirmed: (isModified, selected, selectedInfo) {
                  onConfirmed.call(isModified, selected, selectedInfo);
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

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selected);
    infos = widget.infos;
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
        ? infos
            .where((element) =>
                element.value.toLowerCase().contains(filterText.toLowerCase()))
            .toList()
        : infos;

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
                              color: Colors.grey.withOpacity(0.8)),
                        ),
                      ),
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
                  selectedInfo = [];
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
                widget.onConfirmed.call(isModified, selected, selectedInfo);
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
