import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/app_theme_data.dart';
import 'package:hiqradio/src/blocs/app_config/app_config.dart';
import 'package:hiqradio/src/blocs/config_form/config_form_bloc.dart';
import 'package:hiqradio/src/views/desktop/home_page.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(900.0, 600.0),
    // minimumSize: Size(kMinWindowWidth, kMinWindowWidth),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // 为了使有TextEdit的Frameless window Title bar 的可以选择文本
    // 只能如此，猥琐发育
    await windowManager.setMovable(false);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const BlocWrap(child: MyApp()));

  // runApp(const MyApp());
}

class BlocWrap extends StatelessWidget {
  final Widget child;
  const BlocWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<AppConfigCubit>(
        create: (_) => AppConfigCubit(title: "title"),
      ),
      BlocProvider<ConfigFormBloc>(
        create: (_) => ConfigFormBloc(),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      builder: ((context, child) {
        child = virtualWindowFrameBuilder(context, child);
        return child;
      }),
      home: const HomePage(),
    );
  }
}
