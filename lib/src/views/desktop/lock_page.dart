import 'package:flutter/material.dart';
import 'package:hiqradio/src/utils/check_license.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/crypt.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/components/title_bar.dart';
import 'package:hiqradio/src/views/desktop/components/win_ready.dart';
import 'package:hiqradio/src/views/desktop/home_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  final TextEditingController editingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color toastColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      body: Column(
        children: [
          const TitleBar(
            withFuncs: false,
          ),
          Expanded(
              child: Center(
            child: Row(
              children: [
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          child: const Text(
                            '注册码(32位):',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Container(
                          width: 320,
                          height: 48,
                          padding: const EdgeInsets.symmetric(vertical: 1.0),
                          child: TextField(
                            controller: editingController,
                            focusNode: focusNode,
                            autofocus: true,
                            obscureText: false,
                            autocorrect: false,
                            obscuringCharacter: '*',
                            cursorWidth: 1.0,
                            cursorColor:
                                Theme.of(context).textTheme.bodyMedium!.color!,
                            // style: const TextStyle(fontSize: 15.0),
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color!),
                                  borderRadius: BorderRadius.circular(5)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color!),
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            onSubmitted: (text) {
                              focusNode.requestFocus();
                              onSubmitted(toastColor);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        InkClick(
                            onTap: () => onSubmitted(toastColor),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18.0),
                              alignment: Alignment.center,
                              child: const Text(
                                '注册',
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ))
        ],
      ),
    );
  }

  void onSubmitted(Color backgroundColor) async {
    String license = editingController.text.trim();
    if (license.isEmpty || license.length != 32) {
      showToast(
        '请输入正确的32位注册码',
        backgroundColor: backgroundColor,
        position: const ToastPosition(
          align: Alignment.bottomCenter,
        ),
      );
      return;
    }
    bool isActive =
        await CheckLicense.instance.isActiveLicense(kProductId, license);
    if (!isActive) {
      showToast(
        '注册码无效',
        backgroundColor: backgroundColor,
        position: const ToastPosition(
          align: Alignment.bottomCenter,
        ),
      );
      return;
    }
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(kSpAppLicense, license);

    _jump();
  }

  void _jump() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WinReady(
          child: const HomePage(),
          onReady: () async {
            await windowManager.setTitleBarStyle(TitleBarStyle.hidden,
                windowButtonVisibility: true);
            await windowManager.setFullScreen(false);
            await windowManager.setResizable(false);
            await windowManager.setOpacity(1);
            await windowManager.setSize(const Size(800, 540));
            await windowManager.center();
          },
        ),
      ),
    );
  }
}
