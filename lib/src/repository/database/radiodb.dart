import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:hiqradio/src/repository/database/radiodao.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart' hide Database;
import 'package:sqflite_common/sqlite_api.dart' show Database;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

part 'radiodb.g.dart';

class RadioDB {
  bool isInit = false;
  late Database database;
  late RadioDao radioDao;

  static final RadioDB _instance = RadioDB._();

  static Future<RadioDB> create() async {
    RadioDB db = RadioDB._instance;
    if (!db.isInit) {
      await db.initDb();
    }
    return db;
  }

  RadioDB._();

  Future<String> getDbDirPath() async {
    Directory appDir = await getApplicationSupportDirectory();
    String dirPath = join(appDir.path, 'hiqradio');

    Directory result = Directory(dirPath);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return dirPath;
  }

  void setupDatabase() {
    if (Platform.isWindows) {
      String location = Directory.current.path;
      _windowsInit(join(location, 'sqlite3.dll'));
    }
  }

  void _windowsInit(String path) {
    open.overrideFor(OperatingSystem.windows, () {
      try {
        return DynamicLibrary.open(path);
      } catch (e) {
        stderr.writeln('Failed to load sqlite3.dll at $path');
        rethrow;
      }
    });
    sqlite3.openInMemory().dispose();
  }

  Future<void> initDb() async {
    if (!isInit) {
      setupDatabase();
      String databasesPath = await getDbDirPath();
      String dbPath = join(databasesPath, 'hiqradio.db');

      print('database dir: $dbPath');

      OpenDatabaseOptions options = OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onOpen: _onOpen);

      if (Platform.isWindows || Platform.isLinux) {
        DatabaseFactory databaseFactory = databaseFactoryFfi;
        database = await databaseFactory.openDatabase(
          dbPath,
          options: options,
        );
        return;
      }
      database = await openDatabase(
        dbPath,
        version: options.version,
        onCreate: options.onCreate,
        onUpgrade: options.onUpgrade,
        onOpen: options.onOpen,
      );

      radioDao = RadioDao(db: database);
      isInit = true;
    }
  }

  Future<void> closeDb() async {
    await database.close();
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    print('数据库创建....');
    await createTables(db);
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // await updater.update(db, oldVersion, newVersion);
  }

  FutureOr<void> _onOpen(Database db) {
    print('数据库打开....');
  }
  get dao => radioDao;
}
