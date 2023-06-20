import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/pair.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/play_ctrl.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:hiqradio/src/utils/nav.dart';
import 'package:hiqradio/src/views/desktop/components/nav_bar.dart';
import 'package:hiqradio/src/views/desktop/components/play_bar.dart';
import 'package:hiqradio/src/views/desktop/components/title_bar.dart';
import 'package:hiqradio/src/views/desktop/pages/my_favorite.dart';
import 'package:hiqradio/src/views/desktop/pages/my_station.dart';
import 'package:hiqradio/src/views/desktop/pages/my_recently.dart';
import 'package:hiqradio/src/views/desktop/pages/my_record.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController pageController = PageController(keepPage: true);
  late NavItem actNavItem;
  Color navColor = Colors.red;
  double navContentWidth = 120;

  List<NavItem> topNavTabs = [
    NavItem(
        type: NavType.station,
        pos: NavPos.top,
        // label: '电台',
        iconData: IconFont.station),
  ];

  List<NavItem> bottomNavTabs = [
    NavItem(
        type: NavType.recently,
        pos: NavPos.top,
        // label: '最近',
        iconData: IconFont.recently),
    NavItem(
        type: NavType.record,
        pos: NavPos.top,
        // label: '录音',
        iconData: IconFont.record),
    NavItem(
        type: NavType.mine,
        pos: NavPos.top,
        // label: '我的',
        iconData: IconFont.favorite),
  ];

  bool isCompactMode = false;
  Size preWinSize = const Size(900, 400);

  @override
  void initState() {
    super.initState();
    _registerHotKey();

    // Future.delayed(const Duration(seconds: 5), () {
    //   CacheDownload.download();
    // });

    actNavItem = topNavTabs[0];
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void _registerHotKey() async {
    HotKey hotKey = HotKey(
      KeyCode.space,
      // 设置热键范围（默认为 HotKeyScope.system）
      scope: HotKeyScope.inapp, // 设置为应用范围的热键。
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        Pair<int, Station>? playingInfo =
            context.read<AppCubit>().pauseResume();
        if (playingInfo != null) {
          if (playingInfo.p1 < 0) {
            context.read<RecentlyCubit>().updateRecently(playingInfo.p2);
          } else {
            context.read<RecentlyCubit>().addRecently(playingInfo.p2);
          }
        }
      },
      // 只在 macOS 上工作。
      // keyUpHandler: (hotKey) {
      //   print('onKeyUp+${hotKey.toJson()}');
      // },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: backgroundColor,
      body: Column(
        children: [
          !isCompactMode
              ? Expanded(
                  child: Column(
                    children: [
                      TitleBar(
                        onCompactClicked: () async {
                          Size size = await windowManager.getSize();
                          preWinSize = size;

                          await windowManager.setTitleBarStyle(
                              TitleBarStyle.hidden,
                              windowButtonVisibility: false);
                          setState(() {
                            isCompactMode = !isCompactMode;
                          });
                          await windowManager.setSize(const Size(318.0, 74));
                          await windowManager.setResizable(false);
                        },
                      ),
                      Expanded(
                        child: _buildBody(context),
                      ),
                      const PlayBar()
                    ],
                  ),
                )
              : SizedBox(
                  height: kPlayBarHeight,
                  child: Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          windowManager.startDragging();
                        },
                      ),
                      Center(
                        child: Row(
                          children: [
                            const PlayCtrl(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkClick(
                                child: const Icon(IconFont.quit, size: 20.0),
                                onTap: () async {
                                  await windowManager.setTitleBarStyle(
                                      TitleBarStyle.hidden,
                                      windowButtonVisibility: true);
                                  await windowManager.setSize(preWinSize);

                                  setState(() {
                                    isCompactMode = !isCompactMode;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavBar(
          topNavTabs: topNavTabs,
          bottomNavTabs: bottomNavTabs,
          onTap: (pos, value) => _onNavTabTap(pos, value),
          actType: actNavItem.type,
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(child: _buildNavContent(context))
      ],
    );
  }

  Widget _buildNavContent(BuildContext context) {
    return PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MyStation(),
          // MyCustomized(),
          // MyDiscovery(),
          MyRecently(),
          MyRecord(),
          MyFavorite(),
        ]);
  }

  void _onNavTabTap(NavPos pos, NavItem item) {
    int index = -1;
    if (pos == NavPos.top) {
      index = topNavTabs.indexOf(item);
    } else {
      index = bottomNavTabs.indexOf(item);
      if (index >= 0) {
        index += topNavTabs.length;
      }
    }
    if (index >= 0) {
      pageController.jumpToPage(index);
      setState(() {
        actNavItem = item;
      });
    }
  }
}
