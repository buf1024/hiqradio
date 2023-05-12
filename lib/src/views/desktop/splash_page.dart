import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/app_state.dart';
import 'package:hiqradio/src/views/desktop/components/win_ready.dart';
import 'package:hiqradio/src/views/desktop/home_page.dart';
import 'package:hiqradio/src/views/desktop/lock_page.dart';
import 'package:window_manager/window_manager.dart';

class SplashPage extends StatefulWidget {
  final int maxInitMs;
  const SplashPage({super.key, required this.maxInitMs});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int startMs = DateTime.now().millisecondsSinceEpoch;
  bool isJump = false;
  AlignmentGeometry alignment = Alignment.centerLeft;
  final Duration animateTime = const Duration(milliseconds: 800);
  late Timer tm;

  @override
  void initState() {
    super.initState();
    tm = Timer.periodic(animateTime, (timer) {
      setState(() {
        if (alignment == Alignment.centerLeft) {
          alignment = Alignment.centerRight;
        } else {
          alignment = Alignment.centerLeft;
        }
      });
    });
    context.read<AppCubit>().initApp();
  }

  @override
  void dispose() {
    super.dispose();
    tm.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listener: _listenInitApp,
      child: Scaffold(
        body: Column(
          children: [
            const Spacer(),
            Center(
              child: Stack(
                children: [
                  const SizedBox(
                    width: 150.0,
                    height: 30.0,
                  ),
                  Positioned.fill(
                    child: AnimatedAlign(
                      alignment: alignment,
                      duration: animateTime,
                      child: const Icon(
                        IconFont.station,
                        size: 28.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                '正在初始化，请稍等片刻……',
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _listenInitApp(BuildContext context, AppState state) async {
    if (state.isInit && !isJump) {
      isJump = true;
      int now = DateTime.now().millisecondsSinceEpoch;
      int cost = now - startMs;
      int delay = widget.maxInitMs - cost;
      print('init app cost: $cost ms, delay: $delay ms');
      if (delay > 0) {
        await Future.delayed(Duration(milliseconds: delay));
      }

      _jump(state.isActive ? const HomePage() : const LockPage());
    }
  }

  void _jump(Widget child) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WinReady(
          child: child,
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
