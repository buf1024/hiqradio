import 'dart:io';

import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AppJACubit extends AppCubit {
  AppJACubit() : super();
  @override
  Future<void> audioPlay(
      {required String uri, required bool isRecord, Station? station}) async {
    dynamic tag;
    if (!Platform.isMacOS) {
      tag = MediaItem(
          id: uri,
          title: station == null ? uri : station.name,
          artUri: station != null && station.favicon != null
              ? Uri.parse(station.favicon!)
              : null);
    }
    await player.setAudioSource(
      AudioSource.uri(
        !isRecord ? Uri.parse(uri) : Uri.file(uri),
        tag: tag,
      ),
    );
    await player.play();
  }

  @override
  Future<void> audioStop({required bool isRecord}) async {
    await player.stop();
  }

  @override
  void initAudio() {
    player = AudioPlayer();

    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      emit(state.copyWith(isPlaying: false, playingRecord: null));
    });

    player.playerStateStream.listen((playerState) {
      ProcessingState processingState = playerState.processingState;
      bool isPlaying = true;
      bool isBuffering = false;
      Record? playingRecord = state.playingRecord;
      if (ProcessingState.idle == processingState ||
          ProcessingState.completed == processingState) {
        isPlaying = false;
        playingRecord = null;
      }
      if (playingRecord == null) {
        if (ProcessingState.buffering == processingState ||
            ProcessingState.loading == processingState) {
          isBuffering = true;
        }
      } else {
        isPlaying = false;
        isBuffering = false;
      }
      emit(state.copyWith(
          isPlaying: isPlaying,
          isBuffering: isBuffering,
          playingRecord: playingRecord));
    }, onError: (Object e, StackTrace stackTrace) {
      emit(state.copyWith(
          isPlaying: false, isBuffering: false, playingRecord: null));
    });
  }
  // @override
  // void initAudio() {
  //   player = AudioPlayer();
  //   recordPlayer = AudioPlayer();

  //   player.playbackEventStream.listen((event) {},
  //       onError: (Object e, StackTrace stackTrace) {

  //     emit(state.copyWith(isPlaying: false));
  //   });

  //   player.playerStateStream.listen((playerState) {
  //     ProcessingState processingState = playerState.processingState;
  //     bool isPlaying = true;
  //     bool isBuffering = false;
  //     if (ProcessingState.idle == processingState ||
  //         ProcessingState.completed == processingState) {
  //       isPlaying = false;
  //     }
  //     if (ProcessingState.buffering == processingState ||
  //         ProcessingState.loading == processingState) {
  //       isBuffering = true;
  //     }
  //     emit(state.copyWith(isPlaying: isPlaying, isBuffering: isBuffering));
  //   }, onError: (Object e, StackTrace stackTrace) {

  //     emit(state.copyWith(isPlaying: false, isBuffering: false));
  //   });

  //   recordPlayer.playbackEventStream.listen((event) {},
  //       onError: (Object e, StackTrace stackTrace) {
  //     emit(state.copyWith(playingRecord: null));
  //   });
  //   recordPlayer.playerStateStream.listen((playerState) {
  //     ProcessingState processingState = playerState.processingState;

  //     if (ProcessingState.idle == processingState ||
  //         ProcessingState.completed == processingState) {
  //       emit(state.copyWith(playingRecord: null));
  //     }
  //   }, onError: (Object e, StackTrace stackTrace) {
  //     print('A recordPlayer playerStateStream error occurred: $e');

  //     emit(state.copyWith(playingRecord: null));
  //   });
  // }
}
