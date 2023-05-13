import 'package:flutter/material.dart';

const kAuthor = 'toyent@163.com';

enum HiqThemeMode { dark, light, system }

const kThemeMode = {
  HiqThemeMode.dark: ThemeMode.dark,
  HiqThemeMode.light: ThemeMode.light,
  HiqThemeMode.system: ThemeMode.system
};

const kProductId = 'rd';
const kTryDays = 30;

const kMaxCacheDay = 15;

const kMaxPageSize = 100;
const kDefPageSize = 20;

const kDefListSize = 50;
const kMaxRecentSearch = 10;
const kMaxPlayHis = 50;

const kDefSearchText = '新闻';

const kSpAppLicense = 'SpAppLicense';
const kSpAppFistStarted = 'SpAppFistStarted';
const kSpAppThemeMode = 'SpAppThemeMode';
const kSpAppLastPlayStation = 'AppLastPlayStation';
const kSpAppAutoStart = 'AppAutoStart';
const kSpAppAutoStop = 'AppAutoStop';

const kSpMSLastSearch = 'MSLastSearchText';

const kSpTBLastSearch = 'TBLastSearchText';
