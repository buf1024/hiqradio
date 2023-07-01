import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/utils/nav.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:hiqradio/src/views/phone/components/play_funcs.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_favorite.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_recently.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_record.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_station.dart';
import 'package:hiqradio/src/views/phone/playing_page.dart';

class PhoneHomePage extends StatefulWidget {
  const PhoneHomePage({super.key});

  @override
  State<PhoneHomePage> createState() => _PhoneHomePageState();
}

class _PhoneHomePageState extends State<PhoneHomePage> {
  final PageController pageController = PageController(keepPage: true);
  late NavItem actNavItem;

  TextEditingController searchEditController = TextEditingController();
  FocusNode searchEditFocusNode = FocusNode();

  ScrollController scrollController = ScrollController();

  bool showPlayingStation = true;
  String lastPlayingUrl = '';

  List<NavItem> leftNavTabs = [
    NavItem(
        type: NavType.station,
        pos: NavPos.top,
        // label: '电台',
        iconData: IconFont.station),
    NavItem(
        type: NavType.record,
        pos: NavPos.top,
        // label: '录音',
        iconData: IconFont.record),
  ];

  List<NavItem> rightNavTabs = [
    NavItem(
        type: NavType.recently,
        pos: NavPos.top,
        // label: '收藏',
        iconData: IconFont.recently),
    NavItem(
        type: NavType.mine,
        pos: NavPos.top,
        // label: '我的',
        iconData: IconFont.favorite),
  ];

  @override
  void initState() {
    super.initState();

    actNavItem = leftNavTabs[0];

    initSearch();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();

    searchEditController.dispose();
    searchEditFocusNode.dispose();
  }

  void initSearch() async {
    context.read<SearchCubit>().initSearch();
    String? text = await context.read<SearchCubit>().recentSearch();
    if (text != null) {
      setState(() {
        searchEditController.text = text;
      });
    }
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

    Color dividerColor = Theme.of(context).dividerColor;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            height: 50.0,
            child: TextField(
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: searchEditController,
              focusNode: searchEditFocusNode,
              autofocus: false,
              autocorrect: false,
              obscuringCharacter: '*',
              cursorWidth: 1.0,
              showCursor: true,
              cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
              style: const TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                hintText: '电台搜索',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted: (value) {
                setState(() {});
                context.read<SearchCubit>().search(value);
              },
              onTap: () {
                if (actNavItem.type != leftNavTabs[0].type) {
                  _onNavTabTap(0, leftNavTabs[0]);
                }
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          height: 42.0,
          width: 50.0,
          decoration: BoxDecoration(
            color: dividerColor,
            border: Border.all(
              color: dividerColor,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              if (searchEditController.text.isNotEmpty) {
                setState(() {});
                context.read<SearchCubit>().search(searchEditController.text);
              }
            },
            child: Icon(Icons.search_outlined,
                size: 25.0,
                color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: _searchTextField(),
      ),
      drawer: Drawer(
        width: size.width * 0.718,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 128.0,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0),
                ),
                // margin: EdgeInsets.all(0.0),
                // padding:  EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 2.0),
                child: Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Icon(
                        IconFont.station,
                        color: Theme.of(context).textTheme.bodyMedium!.color!,
                      ),
                    ),
                    const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 4.0,
                          ),
                          // Text('When I was young'),
                          Text('When I was young'),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text('I\'d listen to the HIQ radio'),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text('Waiting for my……'),
                        ])
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),
          _playingStation(),
          _buildNavBar()
        ],
      ),
    );
  }

  Widget _buildBody() {
    return PageView(
        controller: pageController,
        // physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          List<NavItem> tab = leftNavTabs;
          if (index >= 2) {
            tab = rightNavTabs;
            index -= 2;
          }
          setState(() {
            actNavItem = tab[index];
          });
        },
        children: const [
          Center(
            child: MyPhoneStation(),
          ),
          Center(
            child: MyPhoneRecord(),
          ),
          Center(
            child: MyPhoneRecently(),
          ),
          Center(
            child: MyPhoneFavorite(),
          ),
        ]);
  }

  void _onNavTabTap(int index, NavItem item) {
    pageController.jumpToPage(index);
    setState(() {
      actNavItem = item;
    });
  }

  Widget _buildNavBar() {
    return Container(
      height: 68,
      decoration: BoxDecoration(color: Theme.of(context).dividerColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...leftNavTabs
              .asMap()
              .entries
              .map((e) => _navTab(e.key, e.value))
              .toList(),
          _playCtrl(),
          ...rightNavTabs
              .asMap()
              .entries
              .map((e) => _navTab(e.key + leftNavTabs.length, e.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _playCtrl() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    return InkClick(
      child: Container(
        width: 45.0,
        height: 45.0,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45.0),
          color: const Color(0XFFEA3E3C),
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                children: [
                  // 不能完全居中
                  SizedBox(
                    width: !isPlaying ? 11.0 : 7.5,
                  ),
                  Icon(
                    !isPlaying ? IconFont.play : IconFont.stop,
                    size: 20,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            if (isBuffering)
              Center(
                child: SizedBox(
                  height: 45.0,
                  width: 45.0,
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.2),
                    strokeWidth: 2.0,
                  ),
                ),
              )
          ],
        ),
      ),
      onTap: () async {
        if (isPlaying) {
          context.read<AppCubit>().stop();
          if (playingStation != null) {
            context.read<RecentlyCubit>().updateRecently(playingStation);
          }
        } else {
          if (playingStation != null) {
            context.read<AppCubit>().play(playingStation);
            context.read<RecentlyCubit>().addRecently(playingStation);
          }
        }
      },
    );
  }

  Widget _navTab(int index, NavItem elem) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          _onNavTabTap(index, elem);
        },
        child: Container(
          width: 45.0,
          height: 45.0,
          padding: const EdgeInsets.all(5.0),
          child: Icon(
            elem.iconData,
            color: actNavItem.type != elem.type
                ? Theme.of(context).textTheme.bodyMedium!.color!
                : const Color(0XFFEA3E3C),
            weight: 100,
            size: 25.0,
          ),
        ),
      ),
    );
  }

  Widget _playingStation() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    Size winSize = MediaQuery.of(context).size;

    if (playingStation != null &&
        playingStation.urlResolved != lastPlayingUrl) {
      lastPlayingUrl = playingStation.urlResolved;
      showPlayingStation = true;
    }

    return playingStation != null &&
            showPlayingStation &&
            actNavItem.type == NavType.station
        ? Container(
            decoration: BoxDecoration(color: Theme.of(context).dividerColor),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkClick(
                  child: StationInfo(
                    onClicked: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlayingPage(),
                        ),
                      );
                    },
                    width: winSize.width - 106,
                    height: 54,
                    station: playingStation,
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlayingPage(),
                        ),
                      );
                    });
                  },
                ),
                const PlayFuncs(),
              ],
            ),
          )
        : Container();
  }
}
