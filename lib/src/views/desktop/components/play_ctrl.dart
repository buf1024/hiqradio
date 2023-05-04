import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/utils/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:isolate';

class PlayCtrl extends StatefulWidget {
  const PlayCtrl({super.key});

  @override
  State<PlayCtrl> createState() => _PlayCtrlState();
}

class _PlayCtrlState extends State<PlayCtrl> {
  final AudioPlayer player = AudioPlayer();

  final String url = '';

  late Isolate recordIsolate;
  late SendPort recordSendPort;

  void _initIsolate() async {
    ReceivePort recordReceivePort = ReceivePort();
    recordIsolate =
        await Isolate.spawn(doRecordWork, recordReceivePort.sendPort);

    recordReceivePort.listen((message) {
      String cmd = message[0];
      if (cmd == 'new') {
        recordSendPort = message[1];
      } else {
        print('root receive: $message');
      }
    });
  }

  static void doRecordWork(SendPort sendPort) {
    ReceivePort wReceivePort = ReceivePort();
    SendPort wSendPort = wReceivePort.sendPort;
    wReceivePort.listen((message) {
      String cmd = message[0];
      if (cmd == 'start') {
        String url = message[1];
        Record.start(url);
        sendPort.send(['recording', '']);
      } else if (cmd == 'stop') {
        Record.stop();
        sendPort.send(['recorded', '']);
      }
    });
    sendPort.send(['new', wSendPort]);
  }

  @override
  void initState() {
    super.initState();

    _initPlayer();
    _initIsolate();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  Future<void> _initPlayer() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;

    await session.configure(const AudioSessionConfiguration.speech());

    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  Future<void> _setPlayerUrl(String url) async {
    // Try to load audio from a source and catch any errors.
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      print('done set audio');
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.0,
      height: 54.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: const Icon(IconFont.timer, size: 20.0),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Icon(
                IconFont.favoriteFill,
                size: 20.0,
                color: Colors.red.withOpacity(0.8),
              ),
              onTap: () {},
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkClick(
              child: Icon(IconFont.previous,
                  size: 20.0, color: Colors.red.withOpacity(0.8)),
              onTap: () async {
                // String codes =
                //     await rootBundle.loadString('assets/files/emoji-flags.json');
                // List<dynamic> js = jsonDecode(codes);
                // var map = HashMap<String, String>();
                // js.forEach((element) {
                //   Map<String, dynamic> jt = element as Map<String, dynamic>;
                //   var c = jt['code'];
                //   var emoji = jt['emoji'];
                //   if (!map.containsKey(c)) {
                //     map[c] = emoji;
                //   }
                // });
                // print('CN=${map["CN"]}');
              },
            ),
          ),
          StreamBuilder(
            stream: player.playerStateStream,
            builder: ((context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;

              print('processingState: $processingState, playing: $playing');

              return InkClick(
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.red.withOpacity(0.8),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          children: [
                            // 不能完全居中
                            SizedBox(
                              width: ProcessingState.idle == processingState ||
                          ProcessingState.completed == processingState ? 18.0 : 15.0,
                            ),
                            Icon(
                              ProcessingState.idle == processingState ||
                          ProcessingState.completed == processingState
                                  ? IconFont.play
                                  : IconFont.stop,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                      if (ProcessingState.buffering == processingState ||
                          ProcessingState.loading == processingState)
                        Center(
                          child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: CircularProgressIndicator(
                              color: Colors.white.withOpacity(0.2),
                              strokeWidth: 2.0,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                onTap: () async {
                  if (playing != null && playing) {
                    player.stop();
                    // recordSendPort.send(['stop', '']);
                  } else {
                    // String url =
                    //     'https://live-play.cctvnews.cctv.com/cctv/hqzx192.m3u8';
                    String url = 'https://lhttp.qtfm.cn/live/1259/64k.mp3';
                    await _setPlayerUrl(url);
                    player.play();
                    // recordSendPort.send(['start', url]);
                  }
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkClick(
              child: Icon(IconFont.next,
                  size: 20.0, color: Colors.red.withOpacity(0.8)),
              onTap: () {},
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: const Icon(IconFont.record, size: 20.0),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: const Icon(IconFont.share, size: 20.0),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
    ;
  }
}
