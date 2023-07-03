import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/utils/utils.dart';
import 'package:hiqradio/src/views/components/activate.dart';
import 'package:hiqradio/src/views/desktop/components/title_bar.dart';
import 'package:hiqradio/src/views/desktop/components/win_ready.dart';
import 'package:hiqradio/src/views/desktop/home_page.dart';
import 'package:hiqradio/src/views/phone/phone_home_page.dart';
import 'package:window_manager/window_manager.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (isDesktop())
            const TitleBar(
              withFuncs: false,
            ),
          Expanded(
            child: Center(
              child: Activate(
                onActivate: (license, expireDate) async {
                  context.read<AppCubit>().activate(license, expireDate);

                  _jump();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _jump() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isDesktop()
            ? WinReady(
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
              )
            : const PhoneHomePage(),
      ),
    );
  }
}
