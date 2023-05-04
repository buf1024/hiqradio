import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:args/args.dart';

main(List<String> args) async {
  var parser = ArgParser()
    ..addOption("input", abbr: "i", defaultsTo: "./table.sql")
    ..addOption("output", abbr: "o", defaultsTo: "../lib/src/data/tables.dart");
  var results = parser.parse(args);
  String input = results["input"];
  String output = results["output"];

  File file = File(input);
  if (!await file.exists()) {
    // ignore: avoid_print
    print("sql table file $input doesn't exists");
    return;
  }

  String sql = await file.readAsString();

  String result = """//Auto Generated file. Do not edit.

const tabSql = '''
$sql
''';
""";

  File fileOut = File(output);

  if (!await fileOut.exists()) {
    await fileOut.create(recursive: true);
  }
  fileOut.writeAsString(result);

  // ignore: avoid_print
  print("done!\ninput: $input\noutput: $output\n");
}
