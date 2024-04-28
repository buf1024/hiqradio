//Auto Generated file. Do not edit.
part of 'radiodb.dart';

Future<void> createTables(Database db) async {
    await db.execute("""create table `cache`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `tab` VARCHAR(32) NOT NULL,
    `check_time` INTEGER NOT NULL
)
""");
  await db.execute("""CREATE TABLE `station` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `stationuuid` VARCHAR(40) NOT NULL,
    `name` VARCHAR(128) NOT NULL,
    `url_resolved` VARCHAR(256) NOT NULL,
    `homepage` VARCHAR(256) NULL,
    `favicon` VARCHAR(256) NULL,
    `tags` VARCHAR(512) NULL,
    `country` VARCHAR(16) NULL,
    `countrycode` VARCHAR(8) NULL,
    `state` VARCHAR(64) NULL,
    `language` VARCHAR(16) NULL,
    `codec` VARCHAR(16) NULL,
    `bitrate` INTEGER NULL,
    `is_custom` INTEGER NULL
)
""");
  await db.execute("""create index `station_idx` on `station`(
    stationuuid,
    name,
    tags,
    country,
    countrycode,
    state,
    language
)
""");
  await db.execute("""CREATE TABLE `recently` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `stationuuid` VARCHAR(40) NOT NULL,
    `start_time` INTEGER NOT NULL,
    `end_time` INTEGER NULL
)
""");
  await db.execute("""create index `recently_idx` on `recently`(start_time, end_time)
""");
  await db.execute("""CREATE TABLE `record` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `stationuuid` VARCHAR(40) NOT NULL,
    `start_time` INTEGER NOT NULL,
    `end_time` INTEGER NULL,
    `file` VARCHAR(256) NULL
)
""");
  await db.execute("""create index `record_idx` on `record`(start_time, end_time, file)
""");
  await db.execute("""CREATE TABLE `favorite` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `stationuuid` VARCHAR(40) NOT NULL,
    `group_id` INTEGER,
    `create_time` INTEGER
)
""");
  await db.execute("""CREATE TABLE `fav_group` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `create_time` INTEGER NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `desc` VARCHAR(1024) NULL,
    `is_def` INTEGER NULL
)
""");
  await db.execute("""create index `fav_group_idx` on `fav_group`(name)
""");
  await db.execute("""insert into
    `fav_group`(create_time, name, desc, is_def)
values
    (1714278075318, '默认', '默认的Favorite分组', 1);""");
  await db.execute("""insert into
    `cache`(check_time,tab)
values
    (0, 'station');""");

}
