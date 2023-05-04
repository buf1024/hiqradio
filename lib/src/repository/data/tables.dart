//Auto Generated file. Do not edit.

const tabSql = '''
-- 缓存电台
create table `cache`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `table` VARCHAR(32) NOT NULL,
    `check_time` INTEGER NOT NULL
);

create table `state`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `country` VARCHAR(128) NULL,
    `countrycode` VARCHAR(4) NULL,
    `state` VARCHAR(128) NULL,
    `stationcount` INTEGER NULL
);
create index `state_country_code_state_idx` on `state`(country, countrycode, state);

create table `language`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `languagecode` VARCHAR(4) NULL,
    `stationcount` INTEGER NULL
);
create index `language_code_idx` on `language`(languagecode);

create table `tag`(
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `name` VARCHAR(128) NULL,
    `stationcount` INTEGER NULL
);
create index `tag_name_idx` on `tag`(name);

CREATE TABLE `station` (
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
    `bitrate` INTEGER NULL
);
create index `station_idx` on `station`(stationuuid, name, tags, country, countrycode, state, language);

-- 应用数据
CREATE TABLE `station_custom` (
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
    `bitrate` INTEGER NULL
);
create index `station_custom_idx` on `station_custom`(stationuuid, name, tags, country, countrycode, state, language);

CREATE TABLE `recently` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `station_uuid` VARCHAR(40) NOT NULL,
    `start_time` INTEGER NOT NULL,
    `end_time` INTEGER NULL
);
create index `recently_idx` on `recently`(start_time, end_time, last);

CREATE TABLE `record` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `station_uuid` VARCHAR(40) NOT NULL,
    `start_time` INTEGER NOT NULL,
    `end_time` INTEGER NULL,
    `file` VARCHAR(256) NULL,
);
create index `record_idx` on `record`(start_time, end_time, last);


CREATE TABLE `favorite` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `station_uuid` VARCHAR(40) NOT NULL,
    `is_custom`  INTEGER NOT NULL,
    `group_id` INTEGER NULL
);

CREATE TABLE `group` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `name` VARCHAR(40) NOT NULL
);
create index `group_idx` on `group`(name);

''';
