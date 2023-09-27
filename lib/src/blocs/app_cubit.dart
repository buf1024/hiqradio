import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_state.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/pair.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppCubit extends Cubit<AppState> {
  Timer? stopTimer;

  late dynamic player;

  final RadioRepository repo = RadioRepository.instance;

  void initAudio();
  Future<void> audioPlay(
      {required String uri, required bool isRecord, Station? station});
  Future<void> audioStop({required bool isRecord});
  void setVolume(double v) async {}
  double getVolume() {
    return 0;
  }

  AppCubit() : super(const AppState()) {
    initAudio();
  }

  Future<void> _platformPlay(
      {required String uri, required bool isRecord, Station? station}) async {
    try {
      await audioPlay(uri: uri, isRecord: isRecord, station: station);
    } catch (e) {
      print("Error playing : $e");
    }
  }

  Future<void> _platformStop({required bool isRecord}) async {
    try {
      await audioStop(isRecord: isRecord);
    } catch (e) {
      print("Error stopping : $e");
    }
  }

  void initApp() async {
    await ResManager.instance.initRes();
    await repo.initRepo();

    SharedPreferences sp = await SharedPreferences.getInstance();

    String? s = sp.getString(kSpAppLastPlayStation);
    Station? playingStation;
    bool isFavStation = false;
    if (s != null) {
      playingStation = Station.fromJson(jsonDecode(s));
      FavGroup? group = await repo.loadGroup();

      if (group != null) {
        isFavStation =
            await repo.isFavStation(playingStation.stationuuid, group.id!);
      }
    }

    HiqThemeMode themeMode = HiqThemeMode.dark;
    int? theme = sp.getInt(kSpAppThemeMode);
    if (theme != null) {
      themeMode = HiqThemeMode.values[theme];
    }

    bool autoStart = false;
    bool? tmp = sp.getBool(kSpAppAutoStart);
    if (tmp != null) {
      autoStart = tmp;
    }

    bool autoStop = true;
    tmp = sp.getBool(kSpAppAutoStop);
    if (tmp != null) {
      autoStop = tmp;
    }

    bool? autoCache = sp.getBool(kSpAppAutoCache);

    String locale = '';
    String? localeTmp = sp.getString(kSpAppLocale);
    if (localeTmp != null) {
      locale = localeTmp;
    } else {
      locale = 'zh';
    }

    emit(state.copyWith(
        autoCache: autoCache ?? state.autoCache,
        isInit: true,
        playingStation: playingStation,
        themeMode: themeMode,
        autoStart: autoStart,
        autoStop: autoStop,
        locale: locale,
        isFavStation: isFavStation));

    if (autoStart && playingStation != null) {
      play(playingStation);
    }

    int cacheCount = await repo.loadStationCount();
    emit(state.copyWith(isCaching: true, cacheCount: cacheCount));
    // cacheCount = await repo.doCacheStations();
    emit(state.copyWith(isCaching: false, cacheCount: cacheCount));
  }

  void changeThemeMode(HiqThemeMode themeMode) async {
    if (themeMode != state.themeMode) {
      int theme = HiqThemeMode.values.indexOf(themeMode);
      if (theme >= 0) {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setInt(kSpAppThemeMode, theme);
      }
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  void _addPlayHis(Station station) {
    List<Station> stations = List.from(state.playHis);

    int playHisIndex = stations
        .indexWhere((element) => element.urlResolved == station.urlResolved);
    if (playHisIndex < 0) {
      if (stations.length >= kMaxPlayHis) {
        stations.removeAt(0);
      }
      stations.add(station);
      playHisIndex = stations.length - 1;
    }

    emit(state.copyWith(playHis: stations, playHisIndex: playHisIndex));
  }

  void playPrev() async {
    if (state.playHis.isNotEmpty &&
        state.playHisIndex > 0 &&
        state.playHisIndex < state.playHis.length) {
      Station station = state.playHis[state.playHisIndex - 1];
      play(station);
    } else {
      Station? station = await getRandomStation();
      if (station != null) {
        play(station);
      }
    }
  }

  void playNext() async {
    if (state.playHis.isNotEmpty &&
        state.playHisIndex >= 0 &&
        state.playHisIndex < state.playHis.length - 1) {
      Station station = state.playHis[state.playHisIndex + 1];
      play(station);
    } else {
      Station? station = await getRandomStation();
      if (station != null) {
        play(station);
      }
    }
  }

  Future<Station?> getPrevStation() async {
    if (state.playHis.isNotEmpty &&
        state.playHisIndex > 0 &&
        state.playHisIndex < state.playHis.length) {
      return state.playHis[state.playHisIndex - 1];
    } else {
      return await getRandomStation();
    }
  }

  Future<Station?> getStationByUuid(String uuid) async {
    return await repo.loadStationByUuid(uuid);
  }

  Future<Station?> getNextStation() async {
    if (state.playHis.isNotEmpty &&
        state.playHisIndex >= 0 &&
        state.playHisIndex < state.playHis.length - 1) {
      return state.playHis[state.playHisIndex + 1];
    } else {
      return await getRandomStation();
    }
  }

  void play(Station station) async {
    String url = station.urlResolved;
    if (state.playingStation == null ||
        state.playingStation!.urlResolved != url ||
        (state.playingStation!.urlResolved == url && !state.isPlaying)) {
      // last play
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString(kSpAppLastPlayStation, jsonEncode(station.toJson()));

      if (state.playingRecord != null) {
        // await recordPlayer.stop();
        await _platformStop(isRecord: true);
      }
      if (state.playingStation != null && state.isPlaying) {
        // await player.stop();
        _platformStop(isRecord: false);
      }
      _addPlayHis(station);
      FavGroup? group = await repo.loadGroup();
      bool isFavStation = false;
      if (group != null) {
        isFavStation = await repo.isFavStation(station.stationuuid, group.id!);
      }
      emit(state.copyWith(
          playingStation: station,
          isFavStation: isFavStation,
          playingRecord: null));
      // try {
      // await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      // await player.play();
      // } catch (e) {
      //   print("Error loading audio source and play: $e");
      // }
      await _platformPlay(uri: url, isRecord: false, station: station);
    }
  }

  Pair<int, Station>? pauseResume() {
    if (!state.isEditing) {
      if (state.isPlaying) {
        stop();
        return Pair(-1, state.playingStation!);
      } else if (state.playingStation != null) {
        play(state.playingStation!);
        return Pair(1, state.playingStation!);
      }
    }
    return null;
  }

  Pair<int, Station>? playingStatus() {
    if (state.isPlaying) {
      return Pair(1, state.playingStation!);
    } else if (state.playingStation != null) {
      return Pair(-1, state.playingStation!);
    }

    return null;
  }

  void stop() async {
    if (state.playingStation != null) {
      // await player.stop();
      _platformStop(isRecord: false);
    }
  }

  void setEditing(bool isEditing) {
    if (state.isEditing != isEditing) {
      emit(state.copyWith(isEditing: isEditing));
    }
  }

  Future<List<Language>> loadLanguage() async {
    if (state.languages.isEmpty) {
      emit(state.copyWith(isLangLoading: true));

      List<Language> languages = await repo.loadLanguage();

      emit(state.copyWith(languages: languages, isLangLoading: false));
      return languages;
    }
    return state.languages;
  }

  Future<List<Country>> loadCountries() async {
    if (state.countries.isEmpty) {
      emit(state.copyWith(isCountriesLoading: true));

      List<Country> countries = await repo.loadCountries();

      emit(state.copyWith(countries: countries, isCountriesLoading: false));
      return countries;
    }
    return state.countries;
  }

  Future<List<CountryState>> loadStates(String selectedCountry) async {
    if (selectedCountry.isNotEmpty) {
      if (state.states.isEmpty || state.states[selectedCountry] == null) {
        emit(state.copyWith(isStateLoading: true));

        var newState = Map.fromEntries(state.states.entries);
        List<CountryState> countryStates =
            await RadioRepository.instance.loadStates(selectedCountry);
        newState[selectedCountry] = countryStates;
        emit(state.copyWith(states: newState, isStateLoading: false));
        return countryStates;
      } else {
        return state.states[selectedCountry]!;
      }
    }
    return const [];
  }

  Future<List<Tag>> loadTags() async {
    if (state.tags.isEmpty) {
      emit(state.copyWith(isTagLoading: true));

      List<Tag> tags = await repo.loadTags();
      emit(state.copyWith(tags: tags, isTagLoading: false));
      return tags;
    }
    return state.tags;
  }

  void switchFavPlayingStation() {
    emit(state.copyWith(isFavStation: !state.isFavStation));
  }

  void playRecord(Record record) async {
    if (record.file != null && record.file!.isNotEmpty) {
      if (state.playingRecord != null) {
        // await recordPlayer.stop();
        await _platformStop(isRecord: true);
      }
      if (state.playingStation != null && state.isPlaying) {
        // await player.stop();
        await _platformStop(isRecord: false);
      }
      emit(state.copyWith(playingRecord: record));
      // try {
      // await recordPlayer.setAudioSource(AudioSource.file(record.file!));
      // await recordPlayer.play();
      // } catch (e) {
      //   print("Error loading file audio source and play: $e");
      // }
      await _platformPlay(uri: record.file!, isRecord: true);
    }
  }

  void stopPlayRecord() async {
    if (state.playingRecord != null) {
      emit(state.copyWith(playingRecord: null));
      // await recordPlayer.stop();
      await _platformStop(isRecord: true);
    }
  }

  Future<Station?> getRandomStation() async {
    return await repo.loadRandomStation();
  }

  void setAutoStop(bool value) async {
    if (value != state.autoStop) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setBool(kSpAppAutoStop, value);
      emit(state.copyWith(autoStop: value));
    }
  }

  void setAutoStart(bool value) async {
    if (value != state.autoStart) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setBool(kSpAppAutoStart, value);
      emit(state.copyWith(autoStart: value));
    }
  }

  void setAutoCache(bool value) async {
    if (value != state.autoCache) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setBool(kSpAppAutoCache, value);
      repo.setUseCache(value);
      emit(state.copyWith(autoCache: value));
    }
  }

  void changeLocale(String locale) async {
    if (locale != state.locale) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString(kSpAppLocale, locale);

      emit(state.copyWith(locale: locale));
    }
  }

  void cancelStopTimer() {
    _stopStopTimer();
    emit(state.copyWith(stopTimer: -1));
  }

  void restartStopTimer(int millSecs) {
    emit(state.copyWith(stopTimer: millSecs));
    _stopStopTimer();
    _startStopTimer();
  }

  void _startStopTimer() {
    if (stopTimer == null) {
      DateTime now = DateTime.now();
      int tick = (state.stopTimer - now.millisecondsSinceEpoch) ~/ 1000;
      print('tick: $tick');
      stopTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (timer.tick >= tick) {
          _stopStopTimer();
          stop();
        }
      });
    }
  }

  void _stopStopTimer() {
    if (stopTimer != null) {
      stopTimer!.cancel();
      stopTimer = null;
      emit(state.copyWith(stopTimer: -1));
    }
  }
}
