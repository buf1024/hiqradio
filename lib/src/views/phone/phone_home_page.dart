import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/components/activate.dart';
import 'package:hiqradio/src/views/components/gradient_text.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/utils/nav.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:hiqradio/src/views/phone/carplaying_page.dart';
import 'package:hiqradio/src/views/phone/components/play_funcs.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_favorite.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_recently.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_record.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_station.dart';
import 'package:hiqradio/src/views/phone/playing_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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

  DateTime? tmpSleepTime;

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
    text ??= kDefSearchText;

    setState(() {
      searchEditController.text = text!;
    });

    await context.read<SearchCubit>().search(text);
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
              style: const TextStyle(fontSize: 14.0),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).title_search_hit,
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

    bool isCachingApp =
        context.select<AppCubit, bool>((value) => value.state.isCaching);
    bool isCachingSearch =
        context.select<SearchCubit, bool>((value) => value.state.isCaching);
    if (isCachingApp != isCachingSearch) {
      context.read<SearchCubit>().setIsCaching(isCachingApp);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: _searchTextField(),
      ),
      drawer: Drawer(
        width: size.width * 0.75,
        child: ListView(
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
                      height: 60,
                      width: 60,
                      child: Icon(
                        IconFont.station,
                        color: Theme.of(context).textTheme.bodyMedium!.color!,
                        shadows: const [
                          Shadow(blurRadius: 50.0, offset: Offset(0, 5)),
                        ],
                      ),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 4.0,
                          ),
                          // Text('When I was young'),
                          GradientText(
                            'When I was young',
                            style: const TextStyle(
                                fontSize: 13.0, fontStyle: FontStyle.italic),
                            colors: const [
                              Colors.blue,
                              Colors.red,
                              Colors.teal,
                            ],
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          GradientText(
                            'I\'d listen to the HIQ radio',
                            style: const TextStyle(
                                fontSize: 15.0, fontStyle: FontStyle.italic),
                            colors: const [
                              Colors.blue,
                              Colors.red,
                              Colors.teal,
                            ],
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          GradientText(
                            'Waiting for my……',
                            style: const TextStyle(
                                fontSize: 13.0, fontStyle: FontStyle.italic),
                            colors: const [
                              Colors.blue,
                              Colors.red,
                              Colors.teal,
                            ],
                          ),
                        ])
                  ],
                ),
              ),
            ),
            ..._buildConfigItem(),
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

  String _getThemeText(HiqThemeMode themeMode) {
    if (themeMode == HiqThemeMode.dark) {
      return AppLocalizations.of(context).title_theme_dark;
    }
    if (themeMode == HiqThemeMode.light) {
      return AppLocalizations.of(context).title_theme_light;
    }
    return AppLocalizations.of(context).title_theme_system;
  }

  String _getExpireText(bool isTry, String expireDate) {
    String text = AppLocalizations.of(context).cfg_activated;
    if (isTry) {
      text = AppLocalizations.of(context).cfg_try_version;
    }
    if (expireDate.isEmpty) {
      text += AppLocalizations.of(context).cfg_activate_expired;
    } else {
      text += AppLocalizations.of(context).cfg_activate_expired_at(expireDate);
    }
    return text;
  }

  List<Widget> _buildConfigItem() {
    List<HiqThemeMode> themeLabelList = [
      HiqThemeMode.dark,
      HiqThemeMode.light,
      HiqThemeMode.system,
    ];

    bool autoStart =
        context.select<AppCubit, bool>((value) => value.state.autoStart);
    int stopTimer =
        context.select<AppCubit, int>((value) => value.state.stopTimer);
    bool isTry = context.select<AppCubit, bool>((value) => value.state.isTry);
    String expireDate =
        context.select<AppCubit, String>((value) => value.state.expireDate);

    HiqThemeMode themeMode = context
        .select<AppCubit, HiqThemeMode>((value) => value.state.themeMode);

    String locale =
        context.select<AppCubit, String>((value) => value.state.locale);
    if (locale.isEmpty) {
      locale = Platform.localeName.substring(0, 2);
    }
    Map<String, String> localeMap = ResManager.instance.localeMap;

    return [
      ListTile(
        title: const Text(
          'Language',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        subtitle: Text(
          'Current: ${localeMap[locale]}',
        ),
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.of(context).pop();

          showModalBottomSheet(
              context: context,
              elevation: 2.0,
              enableDrag: false,
              backgroundColor: Colors.black.withOpacity(0),
              builder: (context) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Column(
                    children: localeMap.entries.map((entry) {
                      String key = entry.key;
                      String val = entry.value;

                      return InkClick(
                        onTap: () async {
                          context.read<AppCubit>().changeLocale(key);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 16.0),
                                child: key == locale
                                    ? const Icon(
                                        Icons.check,
                                        size: 18.0,
                                      )
                                    : Container(),
                              ),
                              Expanded(
                                child: Text(
                                  val,
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              });
        },
      ),
      ListTile(
        title: Text(
          // '主题',
          AppLocalizations.of(context).title_theme,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context).title_theme}: ${_getThemeText(themeMode)}',
        ),
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.of(context).pop();

          showModalBottomSheet(
              context: context,
              elevation: 2.0,
              enableDrag: false,
              backgroundColor: Colors.black.withOpacity(0),
              builder: (context) {
                return Container(
                  height: 140,
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Column(
                    children: themeLabelList.map((e) {
                      return InkClick(
                        onTap: () {
                          context.read<AppCubit>().changeThemeMode(e);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                          child: Row(
                            children: [
                              Container(
                                width: 60.0,
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 16.0),
                                child: themeMode == e
                                    ? const Icon(
                                        IconFont.check,
                                        size: 18.0,
                                      )
                                    : Container(),
                              ),
                              Expanded(
                                child: Text(
                                  _getThemeText(e),
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              });
        },
      ),
      ListTile(
        title: Text(
          // '驾驶模式',
          AppLocalizations.of(context).cfg_drive_mode,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        subtitle: Text(
          AppLocalizations.of(context).cfg_drive_mode_desc,
        ),
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CarPlayingPage(),
            ),
          );
        },
      ),
      ListTile(
        title: Text(
          stopTimer > 0
              ? AppLocalizations.of(context).cfg_timer_cancel
              : AppLocalizations.of(context).cfg_timer,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        subtitle: stopTimer > 0
            ? Row(
                children: [
                  Text(
                    AppLocalizations.of(context).cfg_timer_cancel_desc,
                  ),
                  Text(
                    DateFormat("HH:mm:ss")
                        .format(DateTime.fromMillisecondsSinceEpoch(stopTimer)),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.withOpacity(0.8),
                    ),
                  )
                ],
              )
            : Text(
                AppLocalizations.of(context).cfg_timer_desc,
              ),
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.of(context).pop();
          showModalBottomSheet(
              context: context,
              elevation: 2.0,
              enableDrag: false,
              backgroundColor: Colors.black.withOpacity(0),
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  if (stopTimer > 0) {
                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 5.0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .cmm_stop_time_confirm,
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  DateFormat("HH:mm:ss").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          stopTimer)),
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.red.withOpacity(0.8)),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MaterialButton(
                                color: Theme.of(context)
                                    .cardColor
                                    .withOpacity(0.8),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  // '取消',
                                  AppLocalizations.of(context).cmm_cancel,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              ),
                              MaterialButton(
                                color: Colors.red.withOpacity(0.8),
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  tmpSleepTime = null;
                                  context.read<AppCubit>().cancelStopTimer();
                                },
                                child: Text(
                                  // '确定',
                                  AppLocalizations.of(context).cmm_confirm,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return WillPopScope(
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0))),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkClick(
                                  child: const SizedBox(
                                    height: 50.0,
                                    width: 50.0,
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 25,
                                    ),
                                  ),
                                  onTap: () {
                                    tmpSleepTime = null;
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Text(
                                  AppLocalizations.of(context).cmm_stop_time,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                InkClick(
                                  child: const SizedBox(
                                    height: 50.0,
                                    width: 50.0,
                                    child: Icon(
                                      Icons.done_outlined,
                                      size: 25,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    if (tmpSleepTime != null) {
                                      var now = DateTime.now();
                                      int ms = (now.hour * 24 +
                                              now.minute * 60 +
                                              now.second) *
                                          1000;

                                      int setMs =
                                          tmpSleepTime!.millisecondsSinceEpoch;
                                      if (setMs < ms) {
                                        setMs += (24 * 60 * 60 * 1000);
                                      }
                                      context.read<AppCubit>().restartStopTimer(
                                          tmpSleepTime!.millisecondsSinceEpoch);
                                    }
                                  },
                                ),
                              ],
                            ),
                            TimePickerSpinner(
                              time: tmpSleepTime,
                              is24HourMode: true,
                              isShowSeconds: true,
                              normalTextStyle: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).hintColor),
                              highlightedTextStyle: TextStyle(
                                  fontSize: 24,
                                  color: Colors.red.withOpacity(0.9)),
                              spacing: 5,
                              itemHeight: 45,
                              isForce2Digits: true,
                              onTimeChange: (time) {
                                setState(() {
                                  tmpSleepTime = time;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      onWillPop: () {
                        tmpSleepTime = null;
                        return Future(
                          () => true,
                        );
                      });
                });
              });
        },
      ),
      ListTile(
          title: Text(
            // '自动播放',
            AppLocalizations.of(context).cfg_auto_play,
            style: const TextStyle(fontSize: 16.0),
          ),
          subtitle: Text(
              // '启动应用时自动播放上次电台'
              AppLocalizations.of(context).cfg_auto_play_desc),
          trailing: Checkbox(
            splashRadius: 0,
            checkColor: Theme.of(context).textTheme.bodyMedium!.color!,
            focusColor: Colors.black.withOpacity(0),
            hoverColor: Colors.black.withOpacity(0),
            activeColor: Colors.black.withOpacity(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            side: MaterialStateBorderSide.resolveWith(
              (states) => BorderSide(
                width: 1.0,
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
            ),
            value: autoStart,
            onChanged: (value) {
              if (value != null && value != autoStart) {
                context.read<AppCubit>().setAutoStart(value);
              }
            },
          ),
          onTap: () {
            context.read<AppCubit>().setAutoStart(!autoStart);
          },
          mouseCursor: SystemMouseCursors.click),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: Text(
          // '激活码',
          AppLocalizations.of(context).cfg_activate_code,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        subtitle: Text(
          _getExpireText(isTry, expireDate),
          style: const TextStyle(fontSize: 13.0),
        ),
        onTap: () {
          Navigator.of(context).pop();
          _onShowActivateDlg((license, expireDate) async {
            context.read<AppCubit>().activate(license, expireDate);
          });
        },
      ),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: Text(
          // '关于本应用',
          AppLocalizations.of(context).cfg_about,
          style: const TextStyle(fontSize: 16.0),
        ),
        subtitle: Text(
          '${ResManager.instance.version} by $kAuthor',
          style: const TextStyle(fontSize: 13.0),
        ),
        onTap: () {
          Navigator.of(context).pop();
          _onShowAboutDlg(locale);
        },
      ),
    ];
  }

  void _onShowAboutDlg(String locale) {
    String chgLog = ResManager.instance.getChgLog(locale);

    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.black.withOpacity(0),
            child: Dialog(
              insetPadding:
                  const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: SizedBox(
                height: size.height*0.7,
                width: size.width - 20.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkClick(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                IconFont.close,
                                size: 22.0,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              AppLocalizations.of(context).cfg_about,
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                      child: Text(
                          'HiqRadio: ${AppLocalizations.of(context).hiqradio} by $kAuthor'),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 5.0, left: 10.0, bottom: 10.0),
                      child: Text(ResManager.instance.version),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: size.width - 20.0,
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 15.0),
                            child: Text(
                              chgLog,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey.withOpacity(0.8)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          child: MaterialButton(
                            color: Colors.red.withOpacity(0.8),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              AppLocalizations.of(context).cmm_confirm,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _onShowActivateDlg(Function(String, String) onActivate) {
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.black.withOpacity(0),
            child: Dialog(
              insetPadding:
                  const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: SizedBox(
                height: 160,
                width: size.width - 10.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkClick(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                IconFont.close,
                                size: 22.0,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              // '激活码',
                              AppLocalizations.of(context).cfg_activate_code,
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Activate(
                            onActivate: onActivate,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
      decoration: BoxDecoration(color: Theme.of(context).canvasColor),
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
                    width: !isPlaying ? 10.0 : 7.5,
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
          Station? station = playingStation;
          station ??= await context.read<AppCubit>().getRandomStation();
          if (station != null) {
            context.read<AppCubit>().play(station);
            context.read<RecentlyCubit>().addRecently(station);
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
          width: 40.0,
          height: 40.0,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: actNavItem.type != elem.type
                  ? null
                  : [
                      BoxShadow(
                        blurRadius: 20.0,
                        color: Colors.black.withOpacity(0.2),
                      )
                    ]),
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
            decoration: BoxDecoration(color: Theme.of(context).canvasColor),
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
