import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:args/args.dart';

main(List<String> args) async {
  var parser = ArgParser()
    ..addOption("font", abbr: "f", defaultsTo: "IconFont")
    ..addOption("input", abbr: "i", defaultsTo: "iconfont.css")
    ..addOption("output", abbr: "o", defaultsTo: "../../lib/app/iconfont.dart");
  var results = parser.parse(args);
  String fontName = results["font"];
  String input = results["input"];
  String output = results["output"];
  print(input);

  String result = """import 'package:flutter/widgets.dart';
//Auto Generated file. Do not edit.

class $fontName {
  $fontName._();
""";
  File fileCss;
  if (input.startsWith("/") || input.startsWith("\\")) {
    fileCss = File(input);
  } else {
    fileCss = File(path.join(Directory.current.path, input));
  }
  if (!await fileCss.exists()) {
    // ignore: avoid_print
    print("font css file $input doesn't exists");
    return;
  }

  String read = await fileCss.readAsString();

  RegExp exp = RegExp(r'\.icon\-(.*?):.*\s.*"\\(.*?)"');
  List<RegExpMatch> allMatches = exp.allMatches(read).toList();

  for (var match in allMatches) {
    String name = match.group(1) ?? '';
    String value = match.group(2) ?? '';
    result +=
        "  static const IconData ${name.replaceAll("-", "_")} = IconData(0x$value, fontFamily: \"$fontName\");\n";
  }

  result += "}";

  File fileOut;

  if (output.startsWith("/") || output.startsWith("\\")) {
    fileOut = File(output);
  } else {
    fileOut = File(path.join(Directory.current.path, output));
  }

  if (!await fileOut.exists()) {
    await fileOut.create(recursive: true);
  }
  fileOut.writeAsString(result);

  var tips = """
flutter:
  fonts:
    - family: $fontName
      fonts:
        - asset: assets/iconfont/iconfont.ttf
""";
  // ignore: avoid_print
  print("done!\ninput: $input\noutput: $output\nremember to add font config to pubspec.yaml, example:\n\n$tips");
}
