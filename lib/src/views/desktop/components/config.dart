import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/views/desktop/components/activate.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  OverlayEntry? activateOverlay;

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
    String text = '已激活。';
    if (isTry) {
      text = '试用版。';
    }
    if (expireDate.isEmpty) {
      text += '激活码已过期。';
    } else {
      text += '激活码将于 $expireDate 过期';
    }
    return text;
  }

  List<Widget> _buildConfigItem() {
    bool autoStart =
        context.select<AppCubit, bool>((value) => value.state.autoStart);
    bool autoStop =
        context.select<AppCubit, bool>((value) => value.state.autoStop);
    bool isTry = context.select<AppCubit, bool>((value) => value.state.isTry);
    String expireDate =
        context.select<AppCubit, String>((value) => value.state.expireDate);
    return [
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: const Text(
            '语言',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
          subtitle: const Text(
            '当前语言: 跟随系统',
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: const Text(
            '自动播放',
            style: TextStyle(fontSize: 14.0),
          ),
          subtitle: const Text('启动应用时自动播放上次电台'),
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
          title: const Text(
            '耳机拔出停止',
            style: TextStyle(fontSize: 14.0),
          ),
          subtitle: const Text(
            '耳机拔出停止播放',
            style: TextStyle(fontSize: 12.0),
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
            value: autoStop,
            onChanged: (value) {
              if (value != null && value != autoStop) {
                context.read<AppCubit>().setAutoStop(value);
              }
            },
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: const Text(
          '激活码',
          style: TextStyle(
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
        title: const Text(
          '关于本应用',
          style: TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text(
          '版本: 1.0.0 $kAuthor',
          style: TextStyle(fontSize: 12.0),
        ),
        onTap: () {},
      ),
    ];
  }

  void _onShowActivateDlg(Function(String, String) onActivate) {
    double width = 420.0;
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
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  '激活码',
                                  style: TextStyle(fontSize: 18.0),
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
}
