import 'package:flutter/material.dart';

const kAuthor = 'toyent@163.com';

enum HiqThemeMode { dark, light, system }

const kThemeMode = {
  HiqThemeMode.dark: ThemeMode.dark,
  HiqThemeMode.light: ThemeMode.light,
  HiqThemeMode.system: ThemeMode.system
};

const kMaxInitMills = 500;

const kProductId = 'rd';
const kTryDays = 30;

const kMaxCacheDay = 15;

const kMaxPageSize = 100;
const kDefPageSize = 20;

const kDefListSize = 50;
const kMaxRecentSearch = 10;
const kMaxPlayHis = 50;

const kDefCheckCacheInterval = 30 * 24 * 60 * 60 * 1000;

const kDefSearchText = 'kids';

const kSpAppLicense = 'SpAppLicense';
const kSpAppFistStarted = 'SpAppFistStarted';
const kSpAppThemeMode = 'SpAppThemeMode';
const kSpAppLastPlayStation = 'AppLastPlayStation';
const kSpAppAutoStart = 'AppAutoStart';
const kSpAppAutoStop = 'AppAutoStop';
const kSpAppAutoCache = 'AppAutoCache';

const kSpMSLastSearch = 'MSLastSearchText';
const kSpMSLastPageSize = 'MSLastPageSize';
const kSpTBLastSearch = 'TBLastSearchText';
const kSpRCLastPageSize = 'RCLastPageSize';

const kSpAppCheckCacheInterval = 'AppCheckCacheInterval';
const kSpAppCheckCacheCodes = 'AppCheckCacheCodes';

const kSpAppLocale = 'AppLocale';

// user
const kSpAppUserAvatar = 'AppUserAvatar';
const kSpAppUserToken = 'AppUserToken';
const kSpAppUserEmail = 'AppUserEmail';
const kSpAppRadioSyncStartTime = 'AppRadioSyncStartTime';
