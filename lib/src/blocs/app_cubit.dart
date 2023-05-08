import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_state.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/repository/database/radiodb.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:just_audio/just_audio.dart';

class AppCubit extends Cubit<AppState> {
  final AudioPlayer player = AudioPlayer();
  final RadioRepository repo = RadioRepository.instance;
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
    await RadioDB.create();
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
      FavGroup? group = await repo.loadGroup();
      bool isFavStation = false;
      if (group != null) {
        isFavStation = await repo.isFavStation(station.stationuuid, group.id!);
      }
      emit(state.copyWith(playingStation: station, isFavStation: isFavStation));
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

      List<Language> languages = await RadioRepository.instance.loadLanguage();

      emit(state.copyWith(languages: languages, isLangLoading: false));
      return languages;
    }
    return state.languages;
  }

  Future<List<Country>> loadCountries() async {
    if (state.countries.isEmpty) {
      emit(state.copyWith(isCountriesLoading: true));

      List<Country> countries = await RadioRepository.instance.loadCountries();

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

      List<Tag> tags = await RadioRepository.instance.loadTags();
      emit(state.copyWith(tags: tags, isTagLoading: false));
      return tags;
    }
    return state.tags;
  }
  void switchFavPlayingStation() {
    emit(state.copyWith(isFavStation: !state.isFavStation));
  }
}
