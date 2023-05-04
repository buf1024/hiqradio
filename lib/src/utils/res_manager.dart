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
  final String languageCode;

  CountryInfo({
    required this.cca2,
    required this.flag,
    required this.name,
    required this.nameNative,
    required this.languageCode,
  });

  factory CountryInfo.fromJson(String cca2, dynamic js) {
    return CountryInfo(
        cca2: cca2,
        flag: js['f'],
        name: js['n'],
        nameNative: js['nn'],
        languageCode: js['l']);
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
      _langMap[key] = LanguageInfo.fromJson(key, value);
    });
    isInit = true;
  }

  get cnL2RMap => _stateL2RMap;
  get cnR2LMap => _stateR2LMap;
  get countryMap => _countryMap;
  get langMap => _langMap;
}
