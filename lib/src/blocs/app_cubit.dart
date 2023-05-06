import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_state.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/repository/radioapi/radioapi.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:just_audio/just_audio.dart';

class AppCubit extends Cubit<AppState> {
  final AudioPlayer player = AudioPlayer();
  AppCubit() : super(const AppState()) {
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
  }

  void initApp() async {
    await ResManager.instance.initRes();
    await Future.delayed(const Duration(milliseconds: 1));
    emit(state.copyWith(isInit: true));
  }

  void play(Station station) async {
    String url = station.urlResolved;
    if (state.playingStation == null ||
        state.playingStation!.urlResolved != url ||
        (state.playingStation!.urlResolved == url && !state.isPlaying)) {
      if (state.playingStation != null && state.isPlaying) {
        await player.stop();
      }
      emit(state.copyWith(playingStation: station));
      try {
        await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
        await player.play();
      } catch (e) {
        print("Error loading audio source and play: $e");
      }
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
      await player.stop();
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
      emit(state.copyWith(languages: languages, isLangLoading: false));
      return languages;
    }
    return state.languages;
  }

  Future<List<Country>> loadCountries() async {
    if (state.countries.isEmpty) {
      emit(state.copyWith(isCountriesLoading: true));

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
      emit(state.copyWith(countries: countries, isCountriesLoading: false));
      return countries;
    }
    return state.countries;
  }

  Future<List<CountryState>> loadStates(String selectedCountry) async {
    if (selectedCountry.isNotEmpty) {
      if (state.states.isEmpty || state.states[selectedCountry] == null) {
        emit(state.copyWith(isStateLoading: true));
        CountryInfo countryInfo =
            ResManager.instance.countryMap[selectedCountry];

        print('selectedCountry: $selectedCountry, countryInfo: $countryInfo');

        Map<String, String> r2lMap = ResManager.instance.cnR2LMap;

        RadioApi api = await RadioApi.create();
        Map<String, CountryState> countryStatesMap = {};
        var countryStatesList =
            await api.states(country: countryInfo.nameRemote);
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
        var newState = Map.fromEntries(state.states.entries);
        List<CountryState> countryStates = countryStatesMap.values.toList();
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

      RadioApi api = await RadioApi.create();
      List<Tag> tags = [];
      var tagsList = await api.tags();
      for (var tag in tagsList) {
        if (tag['name'] == null || (tag['name'] as String).isEmpty) {
          continue;
        }
        tags.add(Tag.fromJson(tag));
      }
      emit(state.copyWith(tags: tags, isTagLoading: false));
      return tags;
    }
    return state.tags;
  }
}
