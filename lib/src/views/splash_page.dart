import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/app_state.dart';
import 'package:hiqradio/src/views/desktop/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hiqradio/src/views/phone/phone_home_page.dart';

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
        body: SafeArea(
          child: Column(
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  // '正在初始化，请稍等片刻……',
                  AppLocalizations.of(context)!.splash_loading,
                ),
              ),
              const Spacer(),
            ],
          ),
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
      _jump(const MyHomePage());
    }
  }

  void _jump(Widget child) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => child,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      return const PhoneHomePage();
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 768) {
        return const HomePage();
      }
      const padding = 0.0;
      var width = (constraints.maxHeight - 2 * padding) / 2.0;
      var height = constraints.maxHeight;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: padding),
        height: height,
        width: width,
        child: const PhoneHomePage(),
      );
    });
  }
}
