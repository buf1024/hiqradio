import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemeData {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        // 外框背景色
        backgroundColor: const Color(0xff3C3F41),
        // 记录激活高亮色
        highlightColor: const Color(0xff0D293E),
        // scaffold 背景颜色
        scaffoldBackgroundColor: const Color(0xff2B2B2B),
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light)),
        // 分割线颜色
        dividerColor: const Color(0xff323232),
        // 弹框菜单主题
        popupMenuTheme: const PopupMenuThemeData(
          textStyle: TextStyle(fontSize: 14, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
        // 主颜色
        primaryColor: Colors.cyan,
        // 主内容文字样式
        textTheme: const TextTheme(
          displayMedium: TextStyle(color: Color(0xffA9B7C6), fontSize: 14),
        ),
        // 输入框填充色
        inputDecorationTheme:
            const InputDecorationTheme(fillColor: Color(0xff45494A)),
        navigationRailTheme: const NavigationRailThemeData(
          // 未选中记录标题样式
          unselectedLabelTextStyle: TextStyle(
            color: Color(0xffBBBBBB),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          // 选中记录标题样式
          selectedLabelTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          // 记录面板颜色
          backgroundColor: Color(0xff3C3F41),
          // 导航栏图标颜色
          indicatorColor: Color(0xffAFB1B3),
          // 激活页签背景色
          selectedIconTheme: IconThemeData(color: Color(0xff2C2E2F)),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        backgroundColor: const Color(0xffF2F2F2),
        highlightColor: Colors.blue.withOpacity(0.1),
        scaffoldBackgroundColor: const Color(0xffFAFAFA),
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.black),
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark)),
        dividerColor: const Color(0xffD1D1D1),
        popupMenuTheme: const PopupMenuThemeData(
          textStyle: TextStyle(fontSize: 14, color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          displayMedium: TextStyle(color: Colors.black, fontSize: 14),
        ),
        inputDecorationTheme:
            const InputDecorationTheme(fillColor: Colors.white),
        navigationRailTheme: const NavigationRailThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Color(0xff6E6E6E),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            selectedIconTheme: IconThemeData(color: Color(0xffBDBDBD))),
      );
}
