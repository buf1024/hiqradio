import 'dart:io';

import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/repository/database/radiodao.dart';
import 'package:hiqradio/src/repository/database/radiodb.dart';
import 'package:hiqradio/src/repository/radioapi/radioapi.dart';
import 'package:hiqradio/src/utils/res_manager.dart';

class RadioRepository {
  static final RadioRepository instance = RadioRepository._();

  RadioRepository._();

  Future<List<Language>> loadLanguage() async {
    RadioApi api = await RadioApi.create();
    List<Language> languages = [];
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
    return languages;
  }

  Future<List<Country>> loadCountries() async {
    RadioApi api = await RadioApi.create();
    List<Country> countries = [];
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
    return countries;
  }

  Future<List<CountryState>> loadStates(String selectedCountry) async {
    CountryInfo countryInfo = ResManager.instance.countryMap[selectedCountry];

    print('selectedCountry: $selectedCountry, countryInfo: $countryInfo');

    Map<String, String> r2lMap = ResManager.instance.cnR2LMap;

    RadioApi api = await RadioApi.create();
    Map<String, CountryState> countryStatesMap = {};
    var countryStatesList = await api.states(country: countryInfo.nameRemote);
    for (var countryState in countryStatesList) {
      if (countryState['name'] == null ||
          (countryState['name'] as String).isEmpty ||
          countryState['country'] == null ||
          (countryState['country'] as String).isEmpty) {
        continue;
      }

      String? mlState = countryState['name'];
      if (selectedCountry == 'CN') {
        mlState = r2lMap[countryState['name']];
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
    RadioApi api = await RadioApi.create();
    List<Tag> tags = [];
    var tagsList = await api.tags();
    for (var tag in tagsList) {
      if (tag['name'] == null || (tag['name'] as String).isEmpty) {
        continue;
      }
      tags.add(Tag.fromJson(tag));
    }
    return tags;
  }

  Future<List<Station>> search(String name,
      {String country = '',
      String countryState = '',
      String language = '',
      List<String> tags = const []}) async {
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
    RadioApi api = await RadioApi.create();
    List<Station> stations = [];

    List<dynamic> stationsList = [];
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

    Set<String> cache = {};

    for (var station in stationsList) {
      if (station['name'] == null ||
          (station['name'] as String).isEmpty ||
          station['url_resolved'] == null ||
          (station['url_resolved'] as String).isEmpty) {
        continue;
      }
      Station sStation = Station.fromJson(station);

      if (sStation.countrycode != null &&
          sStation.countrycode!.toUpperCase() == 'TW') {
        continue;
      }
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
    RadioDao dao = (await RadioDB.create()).dao;
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
    RadioDao dao = (await RadioDB.create()).dao;
    List<FavGroup>? groups = await dao.queryGroups();

    if (groups == null) {
      return const [];
    }

    return groups;
  }

  Future<List<Station>?> loadFavStations(String groupName) async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.queryFavStations(groupName);
  }

  Future<void> addFavorite(Station station, int groupId) async {
    RadioDao dao = (await RadioDB.create()).dao;
    await dao.insertFavorite(station, groupId);
  }

  Future<int> delFavorite(String stationuuid) async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.delFavorite(stationuuid);
  }

  Future<bool> isFavStation(String stationuuid, int groupId) async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.queryIsFavStation(stationuuid, groupId);
  }

  Future<void> updateGroup(int id, {String? name, String? desc}) async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.updateGroup(id, name: name, desc: desc);
  }

  Future<FavGroup> addNewGroup() async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.insertNewGroup();
  }

  Future<void> delGroup(String name) async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.delGroup(name);
  }

  Future<List<String>> loadStationGroup(String stationuuid) async {
    RadioDao dao = (await RadioDB.create()).dao;
    List<FavGroup> data = await dao.queryStationGroup(stationuuid);
    return data.map((e) => e.name).toList();
  }

  Future<void> changeGroup(
      String stationuuid, String oldGroup, List<String> newGroups) async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.changeGroup(stationuuid, oldGroup, newGroups);
  }

  Future<int> clearFavorites(int groupId) async {
    RadioDao dao = (await RadioDB.create()).dao;
    return await dao.delFavorites(groupId);
  }
}
