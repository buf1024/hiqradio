import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/components/activate.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  OverlayEntry? activateOverlay;
  OverlayEntry? languageOverlay;

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
    bool autoStart =
        context.select<AppCubit, bool>((value) => value.state.autoStart);
    bool autoCache =
        context.select<AppCubit, bool>((value) => value.state.autoCache);
    bool isTry = context.select<AppCubit, bool>((value) => value.state.isTry);
    String expireDate =
        context.select<AppCubit, String>((value) => value.state.expireDate);

    String locale =
        context.select<AppCubit, String>((value) => value.state.locale);
    if (locale.isEmpty) {
      locale = Platform.localeName.substring(0, 2);
    }
    Map<String, String> localeMap = ResManager.instance.localeMap;

    return [
      GestureDetector(
        onTapDown: (details) {
          Offset offset = details.globalPosition;
          _onShowLanguageMenu(offset, locale);
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
            AppLocalizations.of(context).cfg_auto_play,
            style: const TextStyle(fontSize: 14.0),
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
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: Text(
            // '缓存电台',
            AppLocalizations.of(context).cfg_cache_station,
            style: const TextStyle(fontSize: 14.0),
          ),
          subtitle: Text(
            // '使用本地缓存电台(建议打开)',
            AppLocalizations.of(context).cfg_cache_station_desc,
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
          // '激活码',
          AppLocalizations.of(context).cfg_activate_code,
          style: const TextStyle(
            fontSize: 14.0,
          ),
        ),
        subtitle: Text(
          _getExpireText(isTry, expireDate),
          style: const TextStyle(fontSize: 12.0),
        ),
        onTap: () {
          _onShowActivateDlg((license, expireDate) async {
            context.read<AppCubit>().activate(license, expireDate);
            _closeActivateOverlay();
          });
        },
      ),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: Text(
          // '关于本应用',
          AppLocalizations.of(context).cfg_about,
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: Text(
          // '版本: 1.0.0 $kAuthor',
          '${AppLocalizations.of(context).cfg_about}: 1.0.0 $kAuthor',
          style: const TextStyle(fontSize: 12.0),
        ),
        onTap: () {},
      ),
    ];
  }

  void _onShowActivateDlg(Function(String, String) onActivate) {
    double width = 484.0;
    Size size = MediaQuery.of(context).size;
    double height = 200;
    activateOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => _closeActivateOverlay(),
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                    ),
                  ),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: InkClick(
                                  onTap: () {
                                    _closeActivateOverlay();
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
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  // '激活码',
                                  AppLocalizations.of(context)
                                      .cfg_activate_code,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(activateOverlay!);
  }

  void _closeActivateOverlay() {
    if (activateOverlay != null) {
      activateOverlay!.remove();
      activateOverlay = null;
    }
  }

  void _onShowLanguageMenu(Offset offset, String locale) {
    Map<String, String> localeMap = ResManager.instance.localeMap;

    double width = 120.0;
    double height = 35.0 * localeMap.length;
    languageOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: kTitleBarHeight),
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
