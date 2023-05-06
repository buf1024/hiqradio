import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
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
  final String url = '';

  late Isolate recordIsolate;
  late SendPort recordSendPort;

  // void _initIsolate() async {
  //   ReceivePort recordReceivePort = ReceivePort();
  //   recordIsolate =
  //       await Isolate.spawn(doRecordWork, recordReceivePort.sendPort);

  //   recordReceivePort.listen((message) {
  //     String cmd = message[0];
  //     if (cmd == 'new') {
  //       recordSendPort = message[1];
  //     } else {
  //       print('root receive: $message');
  //     }
  //   });
  // }

  // static void doRecordWork(SendPort sendPort) {
  //   ReceivePort wReceivePort = ReceivePort();
  //   SendPort wSendPort = wReceivePort.sendPort;
  //   wReceivePort.listen((message) {
  //     String cmd = message[0];
  //     if (cmd == 'start') {
  //       String url = message[1];
  //       Record.start(url);
  //       sendPort.send(['recording', '']);
  //     } else if (cmd == 'stop') {
  //       Record.stop();
  //       sendPort.send(['recorded', '']);
  //     }
  //   });
  //   sendPort.send(['new', wSendPort]);
  // }

  @override
  void initState() {
    super.initState();

    // _initIsolate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);
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
              onTap: () async {},
            ),
          ),
          InkClick(
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
                              width: !isPlaying
                                  ? 18.0
                                  : 15.0,
                            ),
                            Icon(
                              !isPlaying
                                  ? IconFont.play
                                  : IconFont.stop,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                      if (isBuffering)
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
                  if (isPlaying) {
                    context.read<AppCubit>().stop();
                    // recordSendPort.send(['stop', '']);
                  } else {
                    if(playingStation != null) {
                      context.read<AppCubit>().play(playingStation);
                    }
                  }
                },
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
