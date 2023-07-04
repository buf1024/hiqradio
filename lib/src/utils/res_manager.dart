import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class LanguageInfo {
  final String name;
  final String nameNative;
  final String languageCode;

  LanguageInfo({
    required this.name,
    required this.nameNative,
    required this.languageCode,
  });

  factory LanguageInfo.fromJson(String languageCode, dynamic js) {
    return LanguageInfo(
        languageCode: languageCode, name: js['n'], nameNative: js['nn']);
  }
}

class CountryInfo {
  final String cca2;
  final String flag;
  final String name;
  final String nameNative;
  final String nameRemote;
  final String languageCode;

  CountryInfo({
    required this.cca2,
    required this.flag,
    required this.name,
    required this.nameNative,
    required this.nameRemote,
    required this.languageCode,
  });

  factory CountryInfo.fromJson(String cca2, dynamic js) {
    return CountryInfo(
        cca2: cca2,
        flag: js['f'],
        name: js['n'],
        nameNative: js['nn'],
        nameRemote: js['nr'] ?? js['nn'],
        languageCode: js['l']);
  }
  @override
  String toString() {
    return 'CountryInfo{cca2: $cca2, flag: $flag, name: $name, nameNative: $nameNative, nameRemote: $nameRemote, languageCode: $languageCode}';
  }
}
// {"AW": {"f": "🇦🇼", "n": "Aruba", "nn": "Aruba", "l": "nl", "ln": "xxx", "lnn": "xxx"}

class ResManager {
  bool isInit = false;
  ResManager._();

  static ResManager instance = ResManager._();

  final Map<String, List<String>> _stateL2RMap = HashMap();
  final Map<String, String> _stateR2LMap = HashMap();
  final Map<String, CountryInfo> _countryMap = HashMap();
  final Map<String, LanguageInfo> _langMap = HashMap();
  final Map<String, LanguageInfo> _langNameMap = HashMap();
  final Map<String, String> _nativeLangMap = HashMap();
  final Map<String, String> _localeMap = HashMap();
  final Map<String, String> _chgLogMap = HashMap();

  late String _version;

  Future<void> initRes() async {
    if (isInit) {
      return;
    }
    String states = await rootBundle.loadString('assets/files/state.json');
    Map<String, dynamic> map = jsonDecode(states);
    map.forEach((key, value) {
      _stateL2RMap[key] = List.from(value);
    });

    _stateL2RMap.forEach((key, value) {
      for (var element in value) {
        _stateR2LMap[element] = key;
      }
    });

    String countries = await rootBundle.loadString('assets/files/country.json');
    map = jsonDecode(countries);

    map.forEach((key, value) {
      _countryMap[key] = CountryInfo.fromJson(key, value);
    });

    String languages =
        await rootBundle.loadString('assets/files/languages.json');
    map = jsonDecode(languages);
    map.forEach((key, value) {
      LanguageInfo info = LanguageInfo.fromJson(key, value);
      _langMap[key] = info;

      _langNameMap[info.name.toLowerCase()] = LanguageInfo(
          name: info.name,
          nameNative: info.nameNative,
          languageCode: info.languageCode);
    });

    languages = await rootBundle.loadString('assets/files/languages-nmap.json');
    map = jsonDecode(languages);
    map.forEach((key, value) {
      _nativeLangMap[key] = value.toString();
    });

    String locales = await rootBundle.loadString('assets/files/locale.json');
    map = jsonDecode(locales);
    map.forEach((key, value) {
      _localeMap[key] = value as String;
    });

    String chgLog = await rootBundle.loadString('assets/files/chglog-zh.txt');
    chgLog = chgLog.trim();
    _chgLogMap['zh'] = chgLog;
    _version = chgLog.split('\n')[0];

    chgLog = await rootBundle.loadString('assets/files/chglog-en.txt');
    _chgLogMap['en'] = chgLog.trim();

    isInit = true;
  }

  String getLocationText(String? countrycode, String? countryState) {
    String flag = '';
    String country = '';
    if (countrycode != null) {
      Map<String, CountryInfo> map = ResManager.instance.countryMap;
      CountryInfo? countryInfo = map[countrycode];
      if (countryInfo != null) {
        flag = countryInfo.flag;
        country = countryInfo.nameNative;
      }
    }

    countryState = countryState ?? '';

    return '$flag $country $countryState';
  }

  String getLanguageText(String? language) {
    language = language ?? '';
    if (language.isNotEmpty) {
      Map<String, String> map = ResManager.instance.nativeLangMap;
      language = language.toLowerCase();
      if (map.containsKey(language)) {
        language = map[language]!;
      }
    }

    return language;
  }

  String getStationInfoText(
      String? countrycode, String? countryState, String? language) {
    String flag = '';
    if (countrycode != null) {
      Map<String, CountryInfo> map = ResManager.instance.countryMap;
      CountryInfo? countryInfo = map[countrycode];
      if (countryInfo != null) {
        flag = countryInfo.flag;
      }
    }
    language = language ?? '';
    if (language.isNotEmpty) {
      Map<String, String> map = ResManager.instance.nativeLangMap;
      language = language.toLowerCase();
      if (map.containsKey(language)) {
        language = map[language]!;
      }
    }

    countryState = countryState ?? '';

    return '$flag $language $countryState';
  }

  String getChgLog(String locale) {
    if (!_chgLogMap.containsKey(locale)) {
      return '';
    }
    return _chgLogMap[locale]!;
  }

  get cnL2RMap => _stateL2RMap;
  get cnR2LMap => _stateR2LMap;
  get countryMap => _countryMap;
  get langMap => _langMap;
  get langNameMap => _langNameMap;
  get nativeLangMap => _nativeLangMap;
  get localeMap => _localeMap;
  get version => _version;
}
