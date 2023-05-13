import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/app_theme_data.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/my_station_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/record_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/views/desktop/components/win_ready.dart';
import 'package:hiqradio/src/views/desktop/splash_page.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();
  if(Platform.isLinux || Platform.isWindows) {
    DartVLC.initialize();
  }

  WindowOptions windowOptions = const WindowOptions(
    size: Size(400.0, 300.0),
    // minimumSize: Size(kMinWindowWidth, kMinWindowWidth),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // 为了使有TextEdit的Frameless window Title bar 的可以选择文本
    // 只能如此，猥琐发育
    if (!Platform.isWindows) {
      await windowManager.setMovable(false);
    }

    // splash window
    // await windowManager.setTitleBarStyle(TitleBarStyle.hidden,
    //     windowButtonVisibility: false);
    // await windowManager.setResizable(false);
    // await windowManager.setOpacity(0.8);

    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const OKToast(
      child: BlocWrap(
        child: MyApp(),
      ),
    ),
  );
}

class BlocWrap extends StatelessWidget {
  final Widget child;
  const BlocWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<AppCubit>(
        create: (_) => AppCubit(),
      ),
      BlocProvider<MyStationCubit>(
        create: (_) => MyStationCubit(),
      ),
      BlocProvider<FavoriteCubit>(
        create: (_) => FavoriteCubit(),
      ),
      BlocProvider<RecentlyCubit>(
        create: (_) => RecentlyCubit(),
      ),
      BlocProvider<SearchCubit>(
        create: (_) => SearchCubit(),
      ),
      BlocProvider<RecordCubit>(
        create: (_) => RecordCubit(),
      ),
    ], child: child);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    ThemeMode themeMode =
        context.select<AppCubit, ThemeMode>((value) => value.state.hiqThemMode);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      builder: ((context, child) {
        child = virtualWindowFrameBuilder(context, child);
        return child;
      }),
      home: WinReady(
        child: const SplashPage(
          maxInitMs: 500,
        ),
        onReady: () async {
          await windowManager.setTitleBarStyle(TitleBarStyle.hidden,
              windowButtonVisibility: false);
          await windowManager.setResizable(false);
          await windowManager.setOpacity(0.8);
          await windowManager.center();
        },
      ),
    );
  }
}
