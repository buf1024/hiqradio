import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';

class MyIsolate {
  bool isInit = false;
  bool isRecording = false;
  bool isCaching = false;

  late Isolate isolate;
  late SendPort sendPort;
  StreamSubscription<Uint8List>? subscription;

  MyIsolate._();
  static final MyIsolate _instance = MyIsolate._();

  static Future<MyIsolate> create() async {
    MyIsolate api = MyIsolate._instance;
    if (!api.isInit) {
      // await api.initMyIsolate();
      api.initMyIsolate();
    }
    return api;
  }

  void destroy() async {
    isolate.kill();
    subscription = null;
    isInit = false;
  }

  void initMyIsolate() async {
    // Future<void> initMyIsolate() async {
    ReceivePort receivePort = ReceivePort();
    isolate = await Isolate.spawn(_doIsolateWork, receivePort.sendPort);

    receivePort.listen((message) {
      String cmd = message[0];
      if (cmd == 'ready') {
        sendPort = message[1];
      }
    });

    isInit = true;
  }

  Future<void> _downloadStream(String url, String dest) async {
    Response<ResponseBody> rs;
    rs = await Dio().get<ResponseBody>(
      url,
      options: Options(
          responseType: ResponseType.stream), // set responseType to `stream`
    );

    await File(dest).create();

    File file = File(dest);

    subscription = rs.data?.stream.listen((event) {
      try {
        Uint8List bytes = event;
        file.writeAsBytes(bytes, mode: FileMode.append);
      } on Exception catch (_) {
        subscription?.cancel();
      }
    });
  }

  Future<void> _downloadHlsString(String url, String dest) async {
    await File(dest).create();

    File file = File(dest);
    String host = url.substring(0, url.lastIndexOf('/'));
    Set s = {};
    while (isRecording) {
      Response r = await Dio().get(url);
      String data = r.data;
      HlsPlaylist playlist =
          await HlsPlaylistParser.create().parseString(Uri.parse(url), data);
      if (playlist is HlsMasterPlaylist) {
        // master m3u8 file
      } else if (playlist is HlsMediaPlaylist) {
        // media m3u8 file
        List<String?> urls = playlist.segments.map((e) => e.url).toList();
        try {
          for (var u in urls) {
            if (u == null || u.isEmpty) {
              continue;
            }
            if (s.contains(u)) {
              continue;
            }

            s.add(u);
            String mUrl = '$host/$u';
            print('download: $mUrl');

            Response resp = await Dio().get(
              mUrl,
              options: Options(
                responseType: ResponseType.bytes,
              ),
            );
            file.writeAsBytes(resp.data, mode: FileMode.append);
          }
        } on Exception catch (_) {
          stderr.writeln('write file error!');
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // start recording
  void _startRecording(String url, String dest) async {
    isRecording = true;
    if (url.toLowerCase().endsWith('.m3u8')) {
      await _downloadHlsString(url, dest);
    } else {
      await _downloadStream(url, dest);
    }
  }

  void startRecording(String url, String dest) {
    sendPort.send(['record', url, dest]);
  }

  void _stopRecording() {
    isRecording = false;
    subscription?.cancel();
    subscription = null;
  }

  void stopRecording() {
    sendPort.send(['stopRecord']);
  }

  void _doIsolateWork(SendPort sendPort) {
    print('_doIsolateWork ...');
    ReceivePort wReceivePort = ReceivePort();
    SendPort wSendPort = wReceivePort.sendPort;
    wReceivePort.listen((message) {
      String cmd = message[0];
      if (cmd == 'record') {
        String url = message[1];
        String dest = message[2];
        _startRecording(url, dest);
      } else if (cmd == 'stopRecord') {
        _stopRecording();
      }
    });
    sendPort.send(['ready', wSendPort]);
  }
}
