import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/app_ja_cubit.dart';
import 'package:hiqradio/src/blocs/app_vcl_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/my_station_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/record_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/utils/utils.dart';
import 'package:hiqradio/src/views/my_app.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktop()) {
    await windowManager.ensureInitialized();
    await hotKeyManager.unregisterAll();

    if (Platform.isLinux || Platform.isWindows) {
      DartVLC.initialize();
    }

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400.0, 300.0),
      // minimumSize: Size(kMinWindowWidth, kMinWindowWidth),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
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
  }
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
  if (Platform.isAndroid || Platform.isIOS) {
    await JustAudioBackground.init(
        androidNotificationChannelId: 'com.toyent.hiqradio.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        androidShowNotificationBadge: true);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

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
        create: (_) => Platform.isAndroid || Platform.isIOS || Platform.isMacOS
            ? AppJACubit()
            : AppVCLCubit(),
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
