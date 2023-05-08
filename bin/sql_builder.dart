import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:args/args.dart';

main(List<String> args) async {
  var parser = ArgParser()
    ..addOption("input", abbr: "i", defaultsTo: "./table.sql")
    ..addOption("output",
        abbr: "o", defaultsTo: "../lib/src/repository/database/radiodb.g.dart");
  var results = parser.parse(args);
  String input = results["input"];
  String output = results["output"];

  File file = File(input);
  if (!await file.exists()) {
    // ignore: avoid_print
    print("sql table file $input doesn't exists");
    return;
  }

  String sqlCreated = '';
  String tables = await file.readAsString();
  for (String table in tables.split(';')) {
    table = table.trim();
    if (table.isNotEmpty) {
      String sql = '';
      for (String line in table.split('\n')) {
        if (line.startsWith('--')) {
          continue;
        }
        sql = '$sql$line\n';
      }
      sqlCreated = '$sqlCreated  await db.execute("""$sql""");\n';
    }
  }

  int createTime = DateTime.now().millisecondsSinceEpoch;

  String inserted = """insert into
    `fav_group`(create_time, name, desc, is_def)
values
    ($createTime, '默认', '默认的Favorite分组', 1);""";

  inserted = '  await db.execute("""$inserted""");\n';
  sqlCreated = '$sqlCreated$inserted';

  String result = '''//Auto Generated file. Do not edit.
part of 'radiodb.dart';

Future<void> createTables(Database db) async {
  $sqlCreated
}
''';

  File fileOut = File(output);

  if (!await fileOut.exists()) {
    await fileOut.create(recursive: true);
  }
  fileOut.writeAsString(result);

  // ignore: avoid_print
  print("done!\ninput: $input\noutput: $output\n");
}
