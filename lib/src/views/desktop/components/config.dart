import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class Config extends StatefulWidget {
  final VoidCallback? onClose;
  const Config({super.key, this.onClose});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  OverlayEntry? languageOverlay;
  OverlayEntry? aboutOverlay;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: _buildConfigItem(),
      ),
    );
  }

  List<Widget> _buildConfigItem() {
    bool autoStart =
        context.select<AppCubit, bool>((value) => value.state.autoStart);
    bool autoCache =
        context.select<AppCubit, bool>((value) => value.state.autoCache);

    String locale =
        context.select<AppCubit, String>((value) => value.state.locale);
    if (locale.isEmpty) {
      locale = Platform.localeName.substring(0, 2);
    }
    Map<String, String> localeMap = ResManager.instance.localeMap;

    int cacheCount =
        context.select<AppCubit, int>((value) => value.state.cacheCount);

    return [
      GestureDetector(
        onTapDown: (details) {
          Offset offset = Offset(details.globalPosition.dx,
              details.globalPosition.dy - kTitleBarHeight);
          _onShowLanguageMenu(offset, locale);
          widget.onClose!();
        },
        child: ListTile(
            splashColor: Colors.black.withOpacity(0),
            title: const Text(
              'Language',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            subtitle: Text(
              'Current: ${localeMap[locale]}',
            ),
            mouseCursor: SystemMouseCursors.click),
      ),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: Text(
            // '自动播放',
            AppLocalizations.of(context)!.cfg_auto_play,
            style: const TextStyle(fontSize: 14.0),
          ),
          subtitle: Text(
              // '启动应用时自动播放上次电台'
              AppLocalizations.of(context)!.cfg_auto_play_desc),
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
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: Text(
            // '缓存电台',
            AppLocalizations.of(context)!.cfg_cache_station,
            style: const TextStyle(fontSize: 14.0),
          ),
          subtitle: Text(
            // '使用本地缓存电台(建议打开)',
            AppLocalizations.of(context)!.cfg_cache_station_desc,
            style: const TextStyle(fontSize: 12.0),
          ),
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
            value: autoCache,
            onChanged: (value) {
              if (value != null && value != autoCache) {
                context.read<AppCubit>().setAutoCache(value);
              }
            },
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: Text(
          // '关于本应用',
          AppLocalizations.of(context)!.cfg_about,
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: Text(
          '${ResManager.instance.version} by $kAuthor\n${AppLocalizations.of(context)!.cfg_cache} $cacheCount ${AppLocalizations.of(context)!.cmm_stations}',
          style: const TextStyle(fontSize: 12.0),
        ),
        onTap: () {
          _onShowAboutDlg(locale);
          widget.onClose!();
        },
      ),
    ];
  }

  void _onShowAboutDlg(String locale) {
    String chgLog = ResManager.instance.getChgLog(locale);

    double width = 484.0;
    Size size = MediaQuery.of(context).size;
    double height = 300;
    aboutOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 0),
              // padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => _closeAboutOverlay(),
              ),
            ),
            Positioned(
              top: (size.height - height - kTitleBarHeight) / 2 +
                  kTitleBarHeight,
              left: (size.width - width) / 2,
              child: Material(
                color: Colors.black.withOpacity(0),
                child: Dialog(
                  // alignment: Alignment.centerRight,
                  insetPadding: const EdgeInsets.only(
                      top: 0, bottom: 0, right: 0, left: 0),
                  elevation: 2.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: InkClick(
                                  onTap: () {
                                    _closeAboutOverlay();
                                  },
                                  child: const Icon(
                                    IconFont.close,
                                    size: 18.0,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  AppLocalizations.of(context)!.cfg_about,
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                          child: Text(
                              'HiqRadio: ${AppLocalizations.of(context)!.hiqradio} by $kAuthor'),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                          child: InkClick(
                            child: const Row(
                              children: [
                                Text('Github:  '),
                                Text(
                                  'https://github.com/buf1024/hiqradio',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              Uri url = Uri.parse(
                                  'https://github.com/buf1024/hiqradio');
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            },
                          ),
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
                                width: width,
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
                                  _closeAboutOverlay();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.cmm_confirm,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
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
    Overlay.of(context).insert(aboutOverlay!);
  }

  void _closeAboutOverlay() {
    if (aboutOverlay != null) {
      aboutOverlay!.remove();
      aboutOverlay = null;
    }
  }

  void _onShowLanguageMenu(Offset offset, String locale) {
    Map<String, String> localeMap = ResManager.instance.localeMap;

    double width = 120.0;
    double height = 38.0 * localeMap.length;
    languageOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 0),
              // padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => _closeLanguageOverlay(),
              ),
            ),
            Positioned(
              top: offset.dy + 10.0,
              right: 10.0,
              child: Material(
                color: Colors.black.withOpacity(0),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Dialog(
                    // alignment: Alignment.centerRight,
                    insetPadding: const EdgeInsets.only(
                        top: 0, bottom: 0, right: 0, left: 0),
                    elevation: 12.0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Column(
                        children: localeMap.entries.map((entry) {
                          String key = entry.key;
                          String val = entry.value;

                          return InkClick(
                            onTap: () async {
                              context.read<AppCubit>().changeLocale(key);

                              _closeLanguageOverlay();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 30,
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 16.0),
                                    child: key == locale
                                        ? const Icon(
                                            Icons.check,
                                            size: 14.0,
                                          )
                                        : Container(),
                                  ),
                                  Container(
                                    width: 60.0,
                                    padding: const EdgeInsets.only(right: 2.0),
                                    child: Text(
                                      val,
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(languageOverlay!);
  }

  void _closeLanguageOverlay() {
    if (languageOverlay != null) {
      languageOverlay!.remove();
      languageOverlay = null;
    }
  }
}
