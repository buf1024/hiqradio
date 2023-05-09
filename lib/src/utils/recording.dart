import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';

// import Dio repo to handle reading audio stream

class Record {
  static late StreamSubscription<Uint8List>? subscription;
  static List<List<int>> buffer = [];

  // start recording
  static void start(String url) async {
    Response<ResponseBody> rs;
    rs = await Dio().get<ResponseBody>(
      url,
      options: Options(
          responseType: ResponseType.stream), // set responseType to `stream`
    );
    subscription = rs.data?.stream.listen((event) async {
      Uint8List data = event;
      try {
        buffer.add(data);
      } on Exception catch (e) {
        print(e);
      }
    });
  }

// Stop recording
  static void stop() async {
    String filePath = '/Users/luoguochun/Downloads/testcc.mp3';
    await File(filePath).create();
    File sysFile = File(filePath);
    var bytes = Uint8List.fromList(buffer.expand((x) => x).toList());
    sysFile.writeAsBytes(bytes);
    subscription?.cancel();
  }
}
