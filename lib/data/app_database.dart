import 'dart:async';

import 'package:floor/floor.dart';
import 'package:photoapp/data/dao/album_dao.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/entity/album_entity.dart';
import 'package:photoapp/data/entity/media_entity.dart';
import 'package:photoapp/data/entity/media_album_entity.dart';
import 'package:photoapp/data/entity/tag_entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [AlbumEntity, MediaEntity, MediaAlbumEntity, TagEntity])
abstract class AppDatabase extends FloorDatabase {
  AlbumDao get albumDao;
  MediaDao get mediaDao;
  TagDao get tagDao;
}
