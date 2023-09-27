import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:just_audio/just_audio.dart';

class AppJACubit extends AppCubit {
  AppJACubit() : super();
  @override
  Future<void> audioPlay(
      {required String uri, required bool isRecord, Station? station}) async {
    await player.setAudioSource(
      AudioSource.uri(
        !isRecord ? Uri.parse(uri) : Uri.file(uri),
        tag: null,
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

    setVolume(0.75);

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
        if (ProcessingState.loading == processingState) {
          isBuffering = true;
        }
        if (ProcessingState.buffering == processingState) {
          // isBuffering = true;
          // web版没用
          isBuffering = false;
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

  @override
  void setVolume(double v) async {
    await player.setVolume(v);
  }

  @override
  double getVolume() {
    return player.volume;
  }
}
