import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/app_theme_data.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/utils.dart';
import 'package:hiqradio/src/views/desktop/components/win_ready.dart';
import 'package:hiqradio/src/views/splash_page.dart';
import 'package:window_manager/window_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder =
        isDesktop() ? VirtualWindowFrameInit() : null;

    ThemeMode themeMode =
        context.select<AppCubit, ThemeMode>((value) => value.state.hiqThemMode);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      builder: isDesktop()
          ? ((context, child) {
              child = virtualWindowFrameBuilder!(context, child);
              return child;
            })
          : null,
      home: isDesktop()
          ? WinReady(
              child: const SplashPage(
                maxInitMs: kMaxInitMills,
              ),
              onReady: () async {
                await windowManager.setTitleBarStyle(TitleBarStyle.hidden,
                    windowButtonVisibility: false);
                await windowManager.setResizable(false);
                await windowManager.setOpacity(0.8);
                await windowManager.center();
              },
            )
          : const SplashPage(
              maxInitMs: kMaxInitMills,
            ),
    );
  }
}
