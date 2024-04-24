import 'dart:async';

import 'package:floor/floor.dart';
import 'package:photoapp/database/album_dao.dart';
import 'package:photoapp/database/media_album_dao.dart';
import 'package:photoapp/database/media_dao.dart';
import 'package:photoapp/database/models/album.dart';
import 'package:photoapp/database/models/media.dart';
import 'package:photoapp/database/models/media_album.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [Album, Media, MediaAlbum])
abstract class AppDatabase extends FloorDatabase {
  AlbumDao get albumDao;
  MediaDao get mediaDao;
  MediaAlbumDao get mediaAlbumDao;
}
