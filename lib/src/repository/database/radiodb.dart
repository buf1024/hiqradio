import 'dart:async';
import 'package:hiqradio/src/repository/database/radiodao.dart';

// ignore: depend_on_referenced_packages, unnecessary_import
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

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

  Future<void> initDb() async {
    if (!isInit) {
      OpenDatabaseOptions options = OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onOpen: _onOpen);

      DatabaseFactory databaseFactory = databaseFactoryFfiWeb;
      database = await databaseFactory.openDatabase(
        'hiqradio.db',
        options: options,
      );
      radioDao = RadioDao(db: database);
      isInit = true;
      return;
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
