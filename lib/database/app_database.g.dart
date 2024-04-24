// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AlbumDao? _albumDaoInstance;

  MediaDao? _mediaDaoInstance;

  MediaAlbumDao? _mediaAlbumDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `album` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `title` TEXT NOT NULL, `assetEntityThumbnailId` TEXT NOT NULL, `path` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `media` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `assetEntityId` TEXT NOT NULL, `path` TEXT NOT NULL, `dateAddedTimestamp` INTEGER NOT NULL, `dateModifiedTimestamp` INTEGER, `type` TEXT NOT NULL, `isFavorite` INTEGER NOT NULL, `duration` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `media_album` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `imageId` INTEGER NOT NULL, `albumId` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AlbumDao get albumDao {
    return _albumDaoInstance ??= _$AlbumDao(database, changeListener);
  }

  @override
  MediaDao get mediaDao {
    return _mediaDaoInstance ??= _$MediaDao(database, changeListener);
  }

  @override
  MediaAlbumDao get mediaAlbumDao {
    return _mediaAlbumDaoInstance ??= _$MediaAlbumDao(database, changeListener);
  }
}

class _$AlbumDao extends AlbumDao {
  _$AlbumDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _albumInsertionAdapter = InsertionAdapter(
            database,
            'album',
            (Album item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'assetEntityThumbnailId': item.assetEntityThumbnailId,
                  'path': item.path
                }),
        _albumDeletionAdapter = DeletionAdapter(
            database,
            'album',
            ['id'],
            (Album item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'assetEntityThumbnailId': item.assetEntityThumbnailId,
                  'path': item.path
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Album> _albumInsertionAdapter;

  final DeletionAdapter<Album> _albumDeletionAdapter;

  @override
  Future<List<Album>> findAllAlbum() async {
    return _queryAdapter.queryList('SELECT * FROM album',
        mapper: (Map<String, Object?> row) => Album(
            row['id'] as int,
            row['title'] as String,
            row['assetEntityThumbnailId'] as String,
            row['path'] as String));
  }

  @override
  Future<List<Album>> findAlbumByTitle(String title) async {
    return _queryAdapter.queryList('SELECT * FROM album WHERE title = ?1',
        mapper: (Map<String, Object?> row) => Album(
            row['id'] as int,
            row['title'] as String,
            row['assetEntityThumbnailId'] as String,
            row['path'] as String),
        arguments: [title]);
  }

  @override
  Future<List<Album>> findAlbumById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM album WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Album(
            row['id'] as int,
            row['title'] as String,
            row['assetEntityThumbnailId'] as String,
            row['path'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertAlbum(Album album) async {
    await _albumInsertionAdapter.insert(album, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAlbum(Album album) async {
    await _albumDeletionAdapter.delete(album);
  }
}

class _$MediaDao extends MediaDao {
  _$MediaDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mediaInsertionAdapter = InsertionAdapter(
            database,
            'media',
            (Media item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'assetEntityId': item.assetEntityId,
                  'path': item.path,
                  'dateAddedTimestamp': item.dateAddedTimestamp,
                  'dateModifiedTimestamp': item.dateModifiedTimestamp,
                  'type': item.type,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'duration': item.duration
                }),
        _mediaDeletionAdapter = DeletionAdapter(
            database,
            'media',
            ['id'],
            (Media item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'assetEntityId': item.assetEntityId,
                  'path': item.path,
                  'dateAddedTimestamp': item.dateAddedTimestamp,
                  'dateModifiedTimestamp': item.dateModifiedTimestamp,
                  'type': item.type,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'duration': item.duration
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Media> _mediaInsertionAdapter;

  final DeletionAdapter<Media> _mediaDeletionAdapter;

  @override
  Future<List<Media>> findAllMedia() async {
    return _queryAdapter.queryList('SELECT * FROM media',
        mapper: (Map<String, Object?> row) => Media(
            row['id'] as String,
            row['assetEntityId'] as String,
            row['name'] as String,
            row['path'] as String,
            row['dateAddedTimestamp'] as int,
            row['dateModifiedTimestamp'] as int?,
            row['type'] as String,
            row['duration'] as String?,
            (row['isFavorite'] as int) != 0));
  }

  @override
  Future<List<Media>> findAllMediabyAlbumId(String albumId) async {
    return _queryAdapter.queryList('SELECT * FROM media WHERE albumId = ?1',
        mapper: (Map<String, Object?> row) => Media(
            row['id'] as String,
            row['assetEntityId'] as String,
            row['name'] as String,
            row['path'] as String,
            row['dateAddedTimestamp'] as int,
            row['dateModifiedTimestamp'] as int?,
            row['type'] as String,
            row['duration'] as String?,
            (row['isFavorite'] as int) != 0),
        arguments: [albumId]);
  }

  @override
  Future<void> insertMedia(Media media) async {
    await _mediaInsertionAdapter.insert(media, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMedia(Media media) async {
    await _mediaDeletionAdapter.delete(media);
  }
}

class _$MediaAlbumDao extends MediaAlbumDao {
  _$MediaAlbumDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mediaAlbumInsertionAdapter = InsertionAdapter(
            database,
            'media_album',
            (MediaAlbum item) => <String, Object?>{
                  'id': item.id,
                  'imageId': item.imageId,
                  'albumId': item.albumId
                }),
        _mediaAlbumDeletionAdapter = DeletionAdapter(
            database,
            'media_album',
            ['id'],
            (MediaAlbum item) => <String, Object?>{
                  'id': item.id,
                  'imageId': item.imageId,
                  'albumId': item.albumId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MediaAlbum> _mediaAlbumInsertionAdapter;

  final DeletionAdapter<MediaAlbum> _mediaAlbumDeletionAdapter;

  @override
  Future<List<MediaAlbum>> findAllMediaAlbum() async {
    return _queryAdapter.queryList('SELECT * FROM media_album',
        mapper: (Map<String, Object?> row) => MediaAlbum(
            row['id'] as int?, row['imageId'] as int, row['albumId'] as int));
  }

  @override
  Future<MediaAlbum?> findExistMediaFromAlbum(
    String albumTitle,
    int mediaId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM media_album WHERE albumId = (SELECT id FROM album WHERE title = ?1) AND imageId = ?2',
        mapper: (Map<String, Object?> row) => MediaAlbum(row['id'] as int?, row['imageId'] as int, row['albumId'] as int),
        arguments: [albumTitle, mediaId]);
  }

  @override
  Future<void> insertMediaToAlbum(MediaAlbum mediaAlbum) async {
    await _mediaAlbumInsertionAdapter.insert(
        mediaAlbum, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMediaFromAlbum(MediaAlbum mediaAlbum) async {
    await _mediaAlbumDeletionAdapter.delete(mediaAlbum);
  }
}
