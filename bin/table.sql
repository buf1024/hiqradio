-- 缓存电台
-- create table `cache`(
--     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
--     `tab` VARCHAR(32) NOT NULL,
--     `check_time` INTEGER NOT NULL
-- );

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
    `bitrate` INTEGER NULL,
    `is_custom` INTEGER NULL
);

create index `station_idx` on `station`(
    stationuuid,
    name,
    tags,
    country,
    countrycode,
    state,
    language
);

-- CREATE TABLE `playlist_detail` (
--     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
--     `stationuuid` VARCHAR(40) NOT NULL,
--     `playlist_id` INTEGER
-- );

-- create index `playlist_detail_idx` on `playlist_detail`(stationuuid, playlist_id);

-- CREATE TABLE `playlist` (
--     `id` INTEGER PRIMARY KEY AUTOINCREMENT,
--     `create_time` INTEGER NOT NULL,
--     `name` VARCHAR(255) NOT NULL,
--     `desc` VARCHAR(1024) NULL
-- );

-- create index `playlist_name_idx` on `playlist`(name);



CREATE TABLE `recently` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `stationuuid` VARCHAR(40) NOT NULL,
    `start_time` INTEGER NOT NULL,
    `end_time` INTEGER NULL
);

create index `recently_idx` on `recently`(start_time, end_time);

CREATE TABLE `record` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `stationuuid` VARCHAR(40) NOT NULL,
    `start_time` INTEGER NOT NULL,
    `end_time` INTEGER NULL,
    `file` VARCHAR(256) NULL
);

create index `record_idx` on `record`(start_time, end_time, file);

CREATE TABLE `favorite` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `stationuuid` VARCHAR(40) NOT NULL,
    `group_id` INTEGER
);

CREATE TABLE `fav_group` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `create_time` INTEGER NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `desc` VARCHAR(1024) NULL,
    `is_def` INTEGER NULL
);

create index `fav_group_idx` on `fav_group`(name);