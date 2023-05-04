import 'package:flutter/material.dart';
import 'package:hiqradio/src/views/desktop/components/search.dart';
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
  const TitleBar(
      {super.key,
      this.child,
      this.onSearchChanged,
      this.onSearchClicked,
      this.onCompactClicked,
      this.onConfigClicked});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  Map<HiqThemeMode, String> themeLabelMap = {
    HiqThemeMode.dark: '深色模式',
    HiqThemeMode.light: '浅色模式',
    HiqThemeMode.system: '跟随系统',
  };
  late HiqThemeMode themeMode;

  TextEditingController searchEditController = TextEditingController();
  FocusNode searchEditNode = FocusNode();

  OverlayEntry? searchOverlay;
  bool isSearchOverlayShowing = false;
  bool isMouseInSearchOverlay = false;

  @override
  void initState() {
    super.initState();
    // TODO from database
    themeMode = HiqThemeMode.system;
    searchEditNode.unfocus();

    // searchEditNode.addListener(() {
    //   if (!searchEditNode.hasFocus) {
    //     _closeOverlay();
    //   }
    // });
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
                onTap: () => _closeOverlay(),
              ),
              Center(child: widget.child ?? Container()),
              _funcButtons()
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
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5.0)),
        textStyle: const TextStyle(color: Colors.white, fontSize: 10.0),
        verticalOffset: 10.0,
        child: Icon(
          iconData,
          size: 16.0,
        ),
      ),
    );
  }

  Widget _searchTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
      height: 26.0,
      width: 220.0,
      child: TextField(
          controller: searchEditController,
          focusNode: searchEditNode,
          autofocus: true,
          autocorrect: false,
          obscuringCharacter: '*',
          cursorWidth: 1.0,
          showCursor: searchEditNode.hasFocus,
          cursorColor: Colors.grey.withOpacity(0.8),
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
                        size: 16.0, color: Colors.grey.withOpacity(0.8)),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
            fillColor: Colors.grey.withOpacity(0.2),
            filled: true,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                borderRadius: BorderRadius.circular(50.0)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                borderRadius: BorderRadius.circular(50.0)),
          ),
          onChanged: (value) {
            setState(() {});
            widget.onSearchChanged?.call(value);
          },
          onTap: () async {
            if (!isSearchOverlayShowing) {
              setState(() {
                isSearchOverlayShowing = true;
                isMouseInSearchOverlay = false;
              });

              Size size = await windowManager.getSize();
              _showSearchDlg(
                  size.height - kTitleBarHeight - kPlayBarHeight, 300);
              widget.onSearchClicked?.call();
            }
          },
          onSubmitted: (value) {
            searchEditNode.requestFocus();
          }),
    );
  }

  Widget _funcButtons() {
    return Row(children: [
      Platform.isLinux || Platform.isLinux ? _windowsButtons() : Container(),
      const Spacer(),
      _searchTextField(),
      const SizedBox(width: 10.0),
      _funcButton((_) {
        widget.onCompactClicked?.call();
      }, '精简模式', IconFont.compactMode),
      const SizedBox(width: 10.0),
      _funcButton((_) {
        widget.onConfigClicked?.call();
      }, '系统配置', IconFont.config),
      const SizedBox(width: 10.0),
      _funcButton((details) {
        _showThemeSwitchDialog(details.globalPosition);
      }, '主题: ${themeLabelMap[themeMode]}', IconFont.theme),
      const SizedBox(
        width: 16.0,
      )
    ]);
  }

  void _showThemeSwitchDialog(Offset offset) {
    showMenu(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        position: RelativeRect.fromLTRB(
            offset.dx, offset.dy + 16.0, offset.dx + 40.0, offset.dy + 40.0),
        items: themeLabelMap.entries.map(
          (e) {
            return PopupMenuItem<Never>(
              mouseCursor: SystemMouseCursors.basic,
              height: 20.0,
              onTap: () {
                setState(() {
                  themeMode = e.key;
                });
              },
              padding: const EdgeInsets.all(0.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                decoration: themeMode == e.key
                    ? BoxDecoration(color: Colors.grey.withOpacity(0.2))
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.value,
                      style: TextStyle(
                          color: themeMode == e.key
                              ? Colors.blue.withOpacity(0.8)
                              : Colors.white.withOpacity(0.8),
                          fontSize: 14.0),
                    )
                  ],
                ),
              ),
            );
          },
        ).toList(),
        elevation: 8.0);
  }

  // void _onThemeSwitch(HiqThemeMode mode) {
  //   if (themeMode != mode) {
  //     setState(() {
  //       themeMode = mode;
  //     });
  //   }
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
                  onDismiss: () => _closeOverlay(),
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

  void _closeOverlay() {
    if (searchOverlay != null &&
        isSearchOverlayShowing &&
        !isMouseInSearchOverlay) {
      searchOverlay!.remove();
      isSearchOverlayShowing = false;
      isMouseInSearchOverlay = false;
    }
  }
}
