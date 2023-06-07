import 'dart:io';

import 'package:hiqradio/src/models/cache.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/repository/database/radiodao.dart';
import 'package:hiqradio/src/repository/database/radiodb.dart';
import 'package:hiqradio/src/repository/radioapi/radioapi.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/pair.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioRepository {
  static final RadioRepository instance = RadioRepository._();

  late RadioApi api;
  late RadioDao dao;

  bool isApiUseCache = true;
  bool isCaching = false;

  RadioRepository._();

  get isUseCache => isApiUseCache && !isCaching;

  void setUseCache(bool useCache) {
    isApiUseCache = useCache;
  }

  Future<void> initRepo() async {
    api = await RadioApi.create();
    dao = (await RadioDB.create()).dao;
  }

  Future<List<Language>> loadLanguage() async {
    List<Language> languages = [];
    if (!isUseCache) {
      var languageList = await api.languages();
      for (var language in languageList) {
        if (language['name'] == null ||
            (language['name'] as String).isEmpty ||
            language['iso_639'] == null ||
            (language['iso_639'] as String).length > 2) {
          continue;
        }
        String langCode = (language['iso_639'] as String).toLowerCase();
        Map<String, LanguageInfo> map = ResManager.instance.langMap;
        if (map.containsKey(langCode)) {
          languages.add(Language.fromJson(language));
        }
      }
    } else {
      List<Map<String, Object?>> datas =
          await dao.queryStationCountByLanguage();
      if (datas.isNotEmpty) {
        Map<String, int> tmpLangMap = {};
        for (var data in datas) {
          String name = data['language']! as String;
          int count = data['count']! as int;
          List<String> names = [];
          if (name.contains(',')) {
            names = name.split(',');
          } else {
            names = [name];
          }
          for (var n in names) {
            if (tmpLangMap.containsKey(n)) {
              tmpLangMap[n] = tmpLangMap[n]! + count;
            } else {
              tmpLangMap[n] = count;
            }
          }
        }
        Map<String, LanguageInfo> map = ResManager.instance.langNameMap;
        for (var element in tmpLangMap.entries) {
          String lang = element.key;
          int count = element.value;
          if (map.containsKey(lang)) {
            LanguageInfo info = map[lang]!;
            languages.add(Language(
                language: info.name,
                languagecode: info.languageCode,
                stationcount: count));
          }
        }
      }
    }
    return languages;
  }

  Future<List<Country>> loadCountries() async {
    List<Country> countries = [];
    if (!isUseCache) {
      var countriesList = await api.countries();
      for (var country in countriesList) {
        if (country['name'] == null ||
            (country['name'] as String).isEmpty ||
            country['iso_3166_1'] == null ||
            (country['iso_3166_1'] as String).length > 2) {
          continue;
        }
        String countryCode = (country['iso_3166_1'] as String).toUpperCase();
        Map<String, CountryInfo> map = ResManager.instance.countryMap;
        if (map.containsKey(countryCode)) {
          countries.add(Country.fromJson(country));
        }
      }
    } else {
      List<Map<String, Object?>> datas =
          await dao.queryStationCountByCountrycode();
      Map<String, CountryInfo> map = ResManager.instance.countryMap;

      for (var data in datas) {
        String countryCode = data['countrycode']! as String;
        if (map.containsKey(countryCode)) {
          CountryInfo info = map[countryCode]!;
          int count = data['count']! as int;
          countries.add(Country(
              country: info.name, countrycode: info.cca2, stationcount: count));
        }
      }
    }
    return countries;
  }

  Future<List<CountryState>> loadStates(String selectedCountry) async {
    CountryInfo countryInfo = ResManager.instance.countryMap[selectedCountry];

    Map<String, String> r2lMap = ResManager.instance.cnR2LMap;
    Map<String, List<String>> l2rMap = ResManager.instance.cnL2RMap;

    Map<String, CountryState> countryStatesMap = {};

    dynamic countryStatesList;
    print(countryInfo.nameRemote);
    if (!isUseCache) {
      countryStatesList = await api.states(country: countryInfo.nameRemote);
    } else {
      countryStatesList =
          await dao.queryStationCountByState(countryInfo.nameRemote);
    }

    for (var countryState in countryStatesList) {
      if (countryState['name'] == null ||
          (countryState['name'] as String).trim().isEmpty ||
          countryState['country'] == null ||
          (countryState['country'] as String).trim().isEmpty) {
        continue;
      }

      String? mlState = countryState['name'];
      if (selectedCountry == 'CN') {
        mlState = r2lMap[countryState['name']];
        if (mlState == null) {
          if (l2rMap.containsKey(countryState['name'])) {
            mlState = countryState['name'];
          }
        }
      }
      if (mlState != null) {
        CountryState? mState = countryStatesMap[mlState];
        CountryState tState = CountryState.fromJson(
            countryState, countryInfo.name, countryInfo.cca2);
        if (mState != null) {
          countryStatesMap[mlState] = CountryState(
              country: countryInfo.name,
              countrycode: countryInfo.cca2,
              state: mlState,
              stationcount: tState.stationcount + mState.stationcount);
        } else {
          tState = CountryState(
              country: countryInfo.name,
              countrycode: countryInfo.cca2,
              state: mlState,
              stationcount: tState.stationcount);
          countryStatesMap[mlState] = tState;
        }
      }
    }
    return countryStatesMap.values.toList();
  }

  Future<List<Tag>> loadTags() async {
    List<Tag> tags = [];
    if (!isUseCache) {
      var tagsList = await api.tags();
      for (var tag in tagsList) {
        if (tag['name'] == null || (tag['name'] as String).isEmpty) {
          continue;
        }
        tags.add(Tag.fromJson(tag));
      }
    } else {
      List<Map<String, Object?>> tagsDB = await dao.queryStationCountByTags();
      Map<String, int> tmpTags = {};
      for (var tag in tagsDB) {
        String name = tag['tags']! as String;
        int count = tag['count']! as int;
        List<String> names = [];
        if (name.contains(',')) {
          names = name.split(',');
        } else {
          names = [name];
        }
        for (var n in names) {
          if (tmpTags.containsKey(n)) {
            tmpTags[n] = tmpTags[n]! + count;
          } else {
            tmpTags[n] = count;
          }
        }
      }
      for (var element in tmpTags.entries) {
        String name = element.key;
        int count = element.value;
        tags.add(Tag(tag: name, stationcount: count));
      }
    }
    return tags;
  }

  Future<List<Station>> search(String name,
      {String country = '',
      String countryState = '',
      String language = '',
      List<String> tags = const [],
      bool skipCache = false}) async {
    if (country.isNotEmpty) {
      Map<String, CountryInfo> map = ResManager.instance.countryMap;
      CountryInfo? countryInfo = map[country];
      if (countryInfo != null) {
        country = countryInfo.name;
      }
    }
    List<String> cnStates = [];
    if (countryState.isNotEmpty && country == 'China') {
      Map<String, List<String>> map = ResManager.instance.cnL2RMap;
      List<String>? stateInfo = map[countryState];
      if (stateInfo != null) {
        cnStates.addAll(stateInfo);
      }
    }
    if (language.isNotEmpty) {
      Map<String, LanguageInfo> map = ResManager.instance.langMap;
      LanguageInfo? languageInfo = map[language];
      if (languageInfo != null) {
        language = languageInfo.name.toLowerCase();
      }
    }
    print(
        'search: $name, country: $country, countryState: $countryState, language: $language, tags: ${tags.join(',')}');
    List<Station> stations = [];

    List<dynamic> stationsList = [];
    if (!isUseCache || skipCache) {
      if (cnStates.isEmpty) {
        stationsList = await api.search(
            name: name,
            country: country.isEmpty ? null : country,
            state: countryState.isEmpty ? null : countryState,
            language: language.isEmpty ? null : language,
            tagList: tags.isEmpty ? null : tags.join(','),
            hidebroken: true);
      } else {
        for (var cnState in cnStates) {
          List<dynamic> list = await api.search(
              name: name,
              country: country.isEmpty ? null : country,
              state: cnState,
              language: language.isEmpty ? null : language,
              tagList: tags.isEmpty ? null : tags.join(','),
              hidebroken: true);
          stationsList.addAll(list);
        }
      }
    } else {
      stationsList = await dao.querySearchStation(
        name: name,
        country: country.isEmpty ? null : country,
        state: countryState.isEmpty ? null : countryState,
        language: language.isEmpty ? null : language,
        tagList: tags.isEmpty ? null : tags.join(','),
      );
    }

    Set<String> cache = {};

    for (var station in stationsList) {
      if (station['name'] == null ||
          (station['name'] as String).isEmpty ||
          station['url_resolved'] == null ||
          (station['url_resolved'] as String).isEmpty) {
        continue;
      }
      Station sStation = Station.fromJson(station);

      // if (sStation.countrycode != null &&
      //     sStation.countrycode!.toUpperCase() == 'TW') {
      //   continue;
      // }
      if (!cache.contains(sStation.urlResolved)) {
        if (((sStation.countrycode != null &&
                    sStation.countrycode!.toUpperCase() == 'CN') ||
                (sStation.country != null &&
                    sStation.country!.toUpperCase() == 'CHINA')) &&
            (sStation.state != null && sStation.state!.isNotEmpty)) {
          Map<String, String> map = ResManager.instance.cnR2LMap;
          String? countryState = map[sStation.state];
          sStation = sStation.copyWith(state: countryState ?? '');
        }

        stations.add(sStation);

        cache.add(sStation.urlResolved);
      }
    }
    return stations;
  }

  Future<FavGroup?> loadGroup({String? groupName}) async {
    if (groupName == null) {
      FavGroup? group = await dao.queryDefGroup();
      if (group == null) {
        stderr.writeln('default group is unexpected null');
        throw 'default group is unexpected null';
      }
      return group;
    } else {
      return await dao.queryGroup(name: groupName);
    }
  }

  Future<List<FavGroup>> loadGroups() async {
    List<FavGroup>? groups = await dao.queryGroups();

    if (groups == null) {
      return const [];
    }

    return groups;
  }

  Future<List<Station>?> loadFavStations(String groupName) async {
    return await dao.queryFavStations(groupName);
  }

  Future<void> addFavorite(Station station, int groupId) async {
    await dao.insertFavorite(station, groupId);
  }

  Future<int> delFavorite(String stationuuid) async {
    return await dao.delFavorite(stationuuid);
  }

  Future<bool> isFavStation(String stationuuid, int groupId) async {
    return await dao.queryIsFavStation(stationuuid, groupId);
  }

  Future<void> updateGroup(int id, {String? name, String? desc}) async {
    return await dao.updateGroup(id, name: name, desc: desc);
  }

  Future<FavGroup> addNewGroup() async {
    return await dao.insertNewGroup();
  }

  Future<void> delGroup(String name) async {
    return await dao.delGroup(name);
  }

  Future<List<String>> loadStationGroup(String stationuuid) async {
    List<FavGroup> data = await dao.queryStationGroup(stationuuid);
    return data.map((e) => e.name).toList();
  }

  Future<void> changeGroup(
      String stationuuid, String oldGroup, List<String> newGroups) async {
    return await dao.changeGroup(stationuuid, oldGroup, newGroups);
  }

  Future<int> clearFavorites(int groupId) async {
    return await dao.delFavorites(groupId);
  }

  // recently
  Future<List<Pair<Station, Recently>>> loadRecently() async {
    List<Recently> recently = await dao.queryRecently();
    List<Pair<Station, Recently>> data = [];
    for (var r in recently) {
      Station? station = await dao.queryStation(r.stationuuid);
      if (station != null) {
        data.add(Pair(station, r));
      }
    }
    return data;
  }

  Future<void> addRecently(Station station) async {
    await dao.insertRecently(station);
  }

  Future<int> updateRecently(int recentlyId) async {
    return await dao.updateRecently(recentlyId);
  }

  Future<int> clearRecently() async {
    return await dao.delRecently();
  }

  // record
  Future<List<Pair<Station, Record>>> loadRecords() async {
    List<Record> recently = await dao.queryRecord();
    List<Pair<Station, Record>> data = [];
    for (var r in recently) {
      Station? station = await dao.queryStation(r.stationuuid);
      if (station != null) {
        data.add(Pair(station, r));
      }
    }
    return data;
  }

  Future<Record> addRecord(Station station, String file) async {
    return await dao.insertRecord(station, file);
  }

  Future<int> updateRecord(int recordId) async {
    return await dao.updateRecord(recordId);
  }

  Future<int> delRecord(int recordId) async {
    return await dao.delRecord(recordId);
  }

  Future<Station?> loadRandomStation() async {
    return await dao.queryRandomStation();
  }

  Future<void> doCacheStations() async {
    Cache? cache = await dao.queryCache();
    bool needUpdate = false;
    if (cache == null) {
      needUpdate = true;
    } else {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int interval =
          sp.getInt(kSpAppCheckCacheInterval) ?? kDefCheckCacheInterval;
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - cache.checkTime > interval) {
        needUpdate = true;
      }
    }
    if (needUpdate) {
      isCaching = true;
      List<Station> stations = await search('', skipCache: true);
      print('update cache stations size=${stations.length}');
      await dao.insertStations(stations);

      await dao.updateCache(cache!.id!, DateTime.now().millisecondsSinceEpoch);

      isCaching = false;
    } else {
      print('no need cache');
    }
    print('done update cache');
  }
}
