import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/views/desktop/components/config.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/components/search.dart';
import 'package:hiqradio/src/views/desktop/components/search_option.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class TitleBar extends StatefulWidget {
  final Widget? child;

  final ValueChanged? onSearchChanged;
  final VoidCallback? onSearchClicked;
  final VoidCallback? onCompactClicked;
  final VoidCallback? onConfigClicked;
  final bool withFuncs;
  const TitleBar(
      {super.key,
      this.child,
      this.onSearchChanged,
      this.onSearchClicked,
      this.onCompactClicked,
      this.onConfigClicked,
      this.withFuncs = true});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  Map<HiqThemeMode, String> themeLabelMap = {
    HiqThemeMode.dark: '深色模式',
    HiqThemeMode.light: '浅色模式',
    HiqThemeMode.system: '跟随系统',
  };

  TextEditingController searchEditController = TextEditingController();
  FocusNode searchEditNode = FocusNode();

  OverlayEntry? searchOverlay;
  bool isSearchOverlayShowing = false;
  bool isMouseInSearchOverlay = false;

  OverlayEntry? searchOptOverlay;

  OverlayEntry? configOverlay;

  OverlayEntry? themeOverlay;

  @override
  void initState() {
    super.initState();
    searchEditNode.unfocus();

    context.read<SearchCubit>().initSearch();

    searchEditNode.addListener(() {
      if (!searchEditNode.hasFocus) {
        context.read<AppCubit>().setEditing(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchEditController.dispose();
    searchEditNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color dividerColor = Theme.of(context).dividerColor;

    return Column(
      children: [
        SizedBox(
          height: kTitleBarHeight,
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (details) {
                  windowManager.startDragging();
                },
                onTap: () => _closeSearchOverlay(),
              ),
              Center(child: widget.child ?? Container()),
              if (widget.withFuncs) _funcButtons()
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: dividerColor,
        )
      ],
    );
  }

  Widget _windowsButtons() {
    Brightness brightness = Theme.of(context).brightness;
    return Row(
      children: [
        WindowCaptionButton.close(
          brightness: brightness,
          onPressed: () {
            windowManager.close();
          },
        ),
        WindowCaptionButton.minimize(
          brightness: brightness,
          onPressed: () async {
            bool isMinimized = await windowManager.isMinimized();
            if (isMinimized) {
              windowManager.restore();
            } else {
              windowManager.minimize();
            }
          },
        ),
      ],
    );
  }

  Widget _funcButton(ValueChanged onTap, String message, IconData iconData) {
    return GestureDetector(
      onTapDown: (details) {
        onTap.call(details);
      },
      child: Tooltip(
        message: message,
        decoration: BoxDecoration(
            color: Colors.black26, borderRadius: BorderRadius.circular(5.0)),
        textStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color!,
            fontSize: 10.0),
        verticalOffset: 10.0,
        child: Icon(
          iconData,
          size: 16.0,
        ),
      ),
    );
  }

  Widget _searchTextField() {
    bool isSetSearch =
        context.select<SearchCubit, bool>((value) => value.state.isSetSearch);
    String searchText =
        context.select<SearchCubit, String>((value) => value.state.searchText);
    if (isSetSearch) {
      searchEditController.text = searchText;
      context.read<SearchCubit>().resetIsSetSearch(false);
    }

    String selectedCountry = context
        .select<SearchCubit, String>((value) => value.state.selectedCountry);
    String selectedState = context
        .select<SearchCubit, String>((value) => value.state.selectedState);
    String selectedLanguage = context
        .select<SearchCubit, String>((value) => value.state.selectedLanguage);
    List<String> selectedTags = context
        .select<SearchCubit, List<String>>((value) => value.state.selectedTags);

    Color dividerColor = Theme.of(context).dividerColor;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 1.0, bottom: 1.0, left: 4.0),
          height: 26.0,
          width: 240.0,
          child: TextField(
            controller: searchEditController,
            focusNode: searchEditNode,
            autocorrect: false,
            obscuringCharacter: '*',
            cursorWidth: 1.0,
            showCursor: true,
            cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
            style: const TextStyle(fontSize: 12.0),
            decoration: InputDecoration(
              hintText: '电台搜索',
              prefixIcon: Icon(Icons.search_outlined,
                  size: 18.0, color: Colors.grey.withOpacity(0.8)),
              suffixIcon: searchEditController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        searchEditController.text = '';
                        setState(() {});
                        widget.onSearchChanged?.call('');
                      },
                      child: Icon(Icons.close_outlined,
                          size: 15.0, color: Colors.grey.withOpacity(0.8)),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
              fillColor: Colors.grey.withOpacity(0.2),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  bottomLeft: Radius.circular(50.0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  bottomLeft: Radius.circular(50.0),
                ),
              ),
            ),
            onSubmitted: (value) {
              setState(() {});
              widget.onSearchChanged?.call(value);
              context.read<SearchCubit>().search(value);
            },
            onTap: () async {
              context.read<AppCubit>().setEditing(true);
              if (!isSearchOverlayShowing) {
                setState(() {
                  isSearchOverlayShowing = true;
                  isMouseInSearchOverlay = false;
                });

                Size size = await windowManager.getSize();
                _showSearchDlg(
                    size.height - kTitleBarHeight - kPlayBarHeight, 365.0);
                widget.onSearchClicked?.call();
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 4.0),
          height: 25.0,
          width: 35.0,
          decoration: BoxDecoration(
              color: dividerColor,
              border: Border.all(
                color: dividerColor,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              )),
          child: GestureDetector(
            onTap: () async {
              if (searchOptOverlay != null) {
                _closeSearchOptOverlay();
              } else {
                _showSearchOptDlg(
                    onOptionChanged: (country, countryState, language, tags) {
                      context.read<SearchCubit>().changeSearchOption(
                          country, countryState, language, tags);
                    },
                    selectedCountry: selectedCountry,
                    selectedLanguage: selectedLanguage,
                    selectedState: selectedState,
                    selectedTags: selectedTags);
              }
            },
            child: Icon(Icons.filter_alt_outlined,
                size: 15.0,
                color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        )
      ],
    );
  }

  Widget _funcButtons() {
    HiqThemeMode themeMode = context
        .select<AppCubit, HiqThemeMode>((value) => value.state.themeMode);

    return Row(children: [
      Platform.isLinux || Platform.isWindows ? _windowsButtons() : Container(),
      const Spacer(),
      _searchTextField(),
      const SizedBox(width: 10.0),
      _funcButton((_) {
        widget.onCompactClicked?.call();
      }, '精简模式', IconFont.compactMode),
      const SizedBox(width: 10.0),
      _funcButton((_) {
        if (configOverlay != null) {
          _closeConfigOverlay();
        } else {
          _onShowConfigDlg();
        }
      }, '系统配置', IconFont.config),
      const SizedBox(width: 10.0),
      _funcButton((details) {
        if (themeOverlay != null) {
          _closeThemeOverlay();
        } else {
          _showThemeSwitchDialog(details.globalPosition, themeMode);
        }
      }, '主题: ${themeLabelMap[themeMode]}', IconFont.theme),
      const SizedBox(
        width: 16.0,
      )
    ]);
  }

  void _showThemeSwitchDialog(Offset offset, HiqThemeMode themeMode) {
    double width = 120.0;
    double height = 100.0;

    themeOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          fit: StackFit.loose,
          children: [
            Container(
              padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => _closeThemeOverlay(),
              ),
            ),
            Positioned(
              top: kTitleBarHeight,
              right: 0,
              width: width,
              height: height,
              child: Material(
                color: Colors.black.withOpacity(0),
                child: Dialog(
                  alignment: Alignment.centerRight,
                  insetPadding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 0, left: 0),
                  elevation: 2.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Column(
                    children: themeLabelMap.entries.map((e) {
                      return InkClick(
                        onTap: () {
                          context.read<AppCubit>().changeThemeMode(e.key);
                          _closeThemeOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              themeMode == e.key
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
                              Text(themeLabelMap[e.key]!)
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(themeOverlay!);
  }

  void _closeThemeOverlay() {
    if (themeOverlay != null) {
      themeOverlay!.remove();
      themeOverlay = null;
    }
  }

  // void _showThemeSwitchDialog(Offset offset, HiqThemeMode themeMode) {
  //   showMenu(
  //       context: context,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(5.0),
  //       ),
  //       position: RelativeRect.fromLTRB(
  //           offset.dx, offset.dy + 16.0, offset.dx + 40.0, offset.dy + 40.0),
  //       items: themeLabelMap.entries.map(
  //         (e) {
  //           return PopupMenuItem<Never>(
  //             mouseCursor: SystemMouseCursors.basic,
  //             height: 20.0,
  //             onTap: () {
  //               context.read<AppCubit>().changeThemeMode(e.key);
  //             },
  //             padding: const EdgeInsets.all(0.0),
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(vertical: 6.0),
  //               decoration: themeMode == e.key
  //                   ? BoxDecoration(color: Colors.grey.withOpacity(0.2))
  //                   : null,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     e.value,
  //                     style: TextStyle(
  //                         color: themeMode == e.key
  //                             ? Colors.blue.withOpacity(0.8)
  //                             : Theme.of(context).textTheme.bodyMedium!.color!,
  //                         fontSize: 14.0),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ).toList(),
  //       elevation: 8.0);
  // }

  void _showSearchDlg(double height, double width) {
    searchOverlay ??= OverlayEntry(
        opaque: false,
        builder: (context) {
          // 猥琐发育
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: kTitleBarHeight),
                child: ModalBarrier(
                  onDismiss: () => _closeSearchOverlay(),
                ),
              ),
              Positioned(
                top: kTitleBarHeight,
                right: 0.0,
                child: Material(
                  child: MouseRegion(
                    onEnter: (event) {
                      isMouseInSearchOverlay = true;
                    },
                    onExit: (event) => isMouseInSearchOverlay = false,
                    child: SizedBox(
                      height: height,
                      width: width,
                      child: const Search(),
                    ),
                  ),
                ),
              )
            ],
          );
        });
    Overlay.of(context).insert(searchOverlay!);
  }

  void _closeSearchOverlay() {
    if (searchOverlay != null &&
        isSearchOverlayShowing &&
        !isMouseInSearchOverlay) {
      searchOverlay!.remove();
      searchOverlay = null;
      isSearchOverlayShowing = false;
      isMouseInSearchOverlay = false;
    }
  }

  void _showSearchOptDlg({
    required Function(String, String, String, List<String>) onOptionChanged,
    required List<String> selectedTags,
    required String selectedLanguage,
    required String selectedCountry,
    required String selectedState,
  }) {
    const double height = 180.0;
    const double width = 320.0;
    Size size = MediaQuery.of(context).size;

    searchOptOverlay ??= OverlayEntry(
        opaque: false,
        builder: (context) {
          // 猥琐发育
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: kTitleBarHeight),
                child: ModalBarrier(
                  onDismiss: () => _closeSearchOptOverlay(),
                ),
              ),
              Positioned(
                top: (size.height - height - kTitleBarHeight) / 2 +
                    kTitleBarHeight,
                left: (size.width - width) / 2,
                child: Material(
                  color: Colors.black.withOpacity(0),
                  child: Dialog(
                    alignment: Alignment.center,
                    elevation: 2.0,
                    insetPadding: const EdgeInsets.all(0),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: width,
                      height: height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: InkClick(
                                  onTap: () {
                                    _closeSearchOptOverlay();
                                  },
                                  child: const Icon(
                                    IconFont.close,
                                    size: 14.0,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  '搜索选项',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          SearchOption(
                              onOptionChanged:
                                  (country, countryState, language, tags) {
                                onOptionChanged(
                                    country, countryState, language, tags);
                              },
                              selectedCountry: selectedCountry,
                              selectedLanguage: selectedLanguage,
                              selectedState: selectedState,
                              selectedTags: selectedTags),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
    Overlay.of(context).insert(searchOptOverlay!);
  }

  void _closeSearchOptOverlay() {
    if (searchOptOverlay != null) {
      searchOptOverlay!.remove();
      searchOptOverlay = null;
    }
  }

  void _onShowConfigDlg() {
    double width = 300.0;
    Size size = MediaQuery.of(context).size;
    double height = size.height - kTextTabBarHeight - kPlayBarHeight;
    configOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => _closeConfigOverlay(),
              ),
            ),
            Positioned(
              top: kTitleBarHeight,
              right: 0,
              child: Material(
                color: Colors.black.withOpacity(0),
                child: Dialog(
                  alignment: Alignment.centerRight,
                  insetPadding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 0, left: 0),
                  elevation: 2.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                    ),
                  ),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: const Column(
                      children: <Widget>[
                        Expanded(child: Config()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(configOverlay!);
  }

  void _closeConfigOverlay() {
    if (configOverlay != null) {
      configOverlay!.remove();
      configOverlay = null;
    }
  }
}
