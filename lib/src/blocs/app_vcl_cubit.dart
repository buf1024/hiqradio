import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/models/station.dart';

class AppVCLCubit extends AppCubit {
  AppVCLCubit() : super();

  @override
  Future<void> audioPlay(
      {required String uri, required bool isRecord, Station? station}) async {
    if (!isRecord) {
      player.open(Media.network(uri));
      emit(state.copyWith(isPlaying: true, isBuffering: true));
    } else {
      // recordPlayer.open(Media.file(File(uri)));
      player.open(Media.file(File(uri)));
    }
  }

  @override
  Future<void> audioStop({required bool isRecord}) async {
    if (!isRecord) {
      player.stop();
      emit(state.copyWith(isPlaying: false, isBuffering: false));
    } else {
      // recordPlayer.stop();
      player.stop();
      emit(state.copyWith(playingRecord: null));
    }
  }

  @override
  void initAudio() {
    player = Player(id: 1);
    // recordPlayer = Player(id: 2);

    player.playbackStream.listen((PlaybackState playbackState) {
      if (state.playingRecord == null) {
        bool isBuffering = false;
        bool isPlaying = false;
        if (playbackState.isPlaying) {
          isPlaying = true;
        }
        emit(state.copyWith(isPlaying: isPlaying, isBuffering: isBuffering));
      } else {
        if (playbackState.isCompleted) {
          emit(state.copyWith(playingRecord: null));
        }
      }
    });

    // recordPlayer.playbackStream.listen((PlaybackState playbackState) {
    //   if (playbackState.isCompleted) {
    //     emit(state.copyWith(playingRecord: null));
    //   }
    // });
  }
}
