import 'dart:convert';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart' hide Record;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_state.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/repository/database/radiodb.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/check_license.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/recording.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCubit extends Cubit<AppState> {
  late dynamic player;
  late dynamic recordPlayer;

  final RadioRepository repo = RadioRepository.instance;

  AppCubit() : super(const AppState()) {
    if (Platform.isMacOS) {
      player = AudioPlayer();
      recordPlayer = AudioPlayer();

      player.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace stackTrace) {
        print('A playbackEventStream error occurred: $e');
        emit(state.copyWith(isPlaying: false));
      });

      player.playerStateStream.listen((playerState) {
        ProcessingState processingState = playerState.processingState;
        bool isPlaying = true;
        bool isBuffering = false;
        if (ProcessingState.idle == processingState ||
            ProcessingState.completed == processingState) {
          isPlaying = false;
        }
        if (ProcessingState.buffering == processingState ||
            ProcessingState.loading == processingState) {
          isBuffering = true;
        }
        emit(state.copyWith(isPlaying: isPlaying, isBuffering: isBuffering));
      }, onError: (Object e, StackTrace stackTrace) {
        print('A playerStateStream error occurred: $e');

        emit(state.copyWith(isPlaying: false, isBuffering: false));
      });

      recordPlayer.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace stackTrace) {
        print('A recordPlayer playbackEventStream error occurred: $e');
        emit(state.copyWith(playingRecord: null));
      });
      recordPlayer.playerStateStream.listen((playerState) {
        ProcessingState processingState = playerState.processingState;

        if (ProcessingState.idle == processingState ||
            ProcessingState.completed == processingState) {
          emit(state.copyWith(playingRecord: null));
        }
      }, onError: (Object e, StackTrace stackTrace) {
        print('A recordPlayer playerStateStream error occurred: $e');

        emit(state.copyWith(playingRecord: null));
      });
    } else {
      player = Player(id: 1);
      recordPlayer = Player(id: 2);

      player.playbackStream.listen((PlaybackState playbackState) {
        bool isBuffering = false;
        bool isPlaying = false;
        if (playbackState.isPlaying) {
          isPlaying = true;
        }
        emit(state.copyWith(isPlaying: isPlaying, isBuffering: isBuffering));
      });

      recordPlayer.playbackStream.listen((PlaybackState playbackState) {
        if (playbackState.isCompleted) {
          emit(state.copyWith(playingRecord: null));
        }
      });
    }
  }

  Future<void> _platformPlay(
      {required String uri, required bool isRecord}) async {
    try {
      if (Platform.isMacOS) {
        if (!isRecord) {
          await player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
          await player.play();
        } else {
          await recordPlayer.setAudioSource(AudioSource.file(uri));
          await recordPlayer.play();
        }
      } else {
        if (!isRecord) {
          player.open(Media.network(uri));
          emit(state.copyWith(isPlaying: true, isBuffering: true));
        } else {
          recordPlayer.open(Media.file(File(uri)));
        }
      }
    } catch (e) {
      print("Error playing : $e");
    }
  }

  Future<void> _platformStop({required bool isRecord}) async {
    try {
      if (Platform.isMacOS) {
        if (!isRecord) {
          await player.stop();
        } else {
          await recordPlayer.stop();
        }
      } else {
        if (!isRecord) {
          player.stop();
          emit(state.copyWith(isPlaying: false, isBuffering: false));
        } else {
          recordPlayer.stop();
          emit(state.copyWith(playingRecord: null));
        }
      }
    } catch (e) {
      print("Error stopping : $e");
    }
  }

  Future<String> getRecordingPath() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dirPath = join(appDir.path, 'hiqradio', 'recording');

    Directory result = Directory(dirPath);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return dirPath;
  }

  void initApp() async {
    await ResManager.instance.initRes();
    await RadioDB.create();
    await Recording.create();

    SharedPreferences sp = await SharedPreferences.getInstance();

    String? s = sp.getString(kSpAppLastPlayStation);
    Station? playingStation;
    if (s != null) {
      playingStation = Station.fromJson(jsonDecode(s));
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
    String? expireDate = await CheckLicense.instance.checkLicense();
    emit(state.copyWith(
        expireDate: expireDate ?? '',
        isInit: true,
        playingStation: playingStation,
        themeMode: themeMode,
        autoStart: autoStart,
        autoStop: autoStop));

    await Future.delayed(const Duration(milliseconds: 1));
    if (expireDate != null) {
      if (autoStart && playingStation != null) {
        play(playingStation);
      }
    }
  }

  void activate(String license, String expireDate) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(kSpAppLicense, license);

    emit(state.copyWith(isTry: false, expireDate: expireDate));
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
    }
  }

  void playNext() async {
    if (state.playHis.isNotEmpty &&
        state.playHisIndex >= 0 &&
        state.playHisIndex < state.playHis.length - 1) {
      Station station = state.playHis[state.playHisIndex + 1];
      play(station);
    }
  }

  Station? getPrevStation() {
    if (state.playHis.isNotEmpty &&
        state.playHisIndex > 0 &&
        state.playHisIndex < state.playHis.length) {
      return state.playHis[state.playHisIndex - 1];
    }
    return null;
  }

  Station? getNextStation() {
    if (state.playHis.isNotEmpty &&
        state.playHisIndex >= 0 &&
        state.playHisIndex < state.playHis.length - 1) {
      return state.playHis[state.playHisIndex + 1];
    }
    return null;
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
      await _platformPlay(uri: url, isRecord: false);
    }
  }

  void pauseResume() async {
    if (!state.isEditing) {
      if (state.isPlaying) {
        stop();
      } else if (state.playingStation != null) {
        play(state.playingStation!);
      }
    }
  }

  void stop() async {
    if (state.playingStation != null) {
      // await player.stop();
      _platformStop(isRecord: false);
    }
  }

  Future<String?> getStationRecordingPath() async {
    if (state.playingStation != null && !state.isRecording) {
      String ext = '';
      String url = state.playingStation!.urlResolved;

      int index = url.lastIndexOf('/');
      if (index != url.length - 1) {
        String file = url.substring(index + 1);
        index = file.indexOf('?');
        if (index > 0) {
          file = file.substring(0, index);
        }
        index = file.indexOf('.');
        if (index >= 0) {
          ext = file.substring(index);
          if (ext.contains('.m3u')) {
            ext = '.ts';
          }
        }
      }
      if (ext.isEmpty) {
        String? codec = state.playingStation!.codec;
        if (codec != null) {
          ext = '.${codec.toLowerCase()}';
        }
      }
      if (ext.isEmpty) {
        ext = '.ts';
      }

      String dest =
          '${DateTime.now().millisecondsSinceEpoch}-${state.playingStation!.name}$ext';
      String basePath = await getRecordingPath();
      dest = '$basePath/$dest';

      return dest;
    }
    return null;
  }

  void startRecording(String dest) async {
    if (state.playingStation != null && !state.isRecording) {
      String url = state.playingStation!.urlResolved;

      print('recording: url=$url, desc=$dest');

      Recording r = await Recording.create();
      r.start(url, dest);

      emit(state.copyWith(isRecording: true));
    }
  }

  Future<void> stopRecording() async {
    if (state.isRecording) {
      Recording r = await Recording.create();
      r.stop();
      emit(state.copyWith(isRecording: false));
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
}
