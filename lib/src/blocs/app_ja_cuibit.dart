import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:just_audio/just_audio.dart';

class AppJACubit extends AppCubit {
  AppJACubit() : super();
  @override
  Future<void> audioPlay({required String uri, required bool isRecord}) async {
    if (!isRecord) {
      await player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await player.play();
    } else {
      await recordPlayer.setAudioSource(AudioSource.file(uri));
      await recordPlayer.play();
    }
  }

  @override
  Future<void> audioStop({required bool isRecord}) async {
    if (!isRecord) {
      await player.stop();
    } else {
      await recordPlayer.stop();
    }
  }

  @override
  void initAudio() {
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
  }
}
