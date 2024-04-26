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

  TagDao? _tagDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `album` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `title` TEXT NOT NULL, `thumbnailPath` TEXT NOT NULL, `path` TEXT NOT NULL, `numberOfItems` INTEGER NOT NULL, `albumType` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `media` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `path` TEXT NOT NULL, `dateAddedTimestamp` INTEGER NOT NULL, `dateModifiedTimestamp` INTEGER, `type` TEXT NOT NULL, `isFavorite` INTEGER NOT NULL, `duration` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `media_album` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `mediaId` INTEGER NOT NULL, `albumId` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `tag` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `color` TEXT NOT NULL, `mediaId` INTEGER NOT NULL, PRIMARY KEY (`id`))');

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
  TagDao get tagDao {
    return _tagDaoInstance ??= _$TagDao(database, changeListener);
  }
}

class _$AlbumDao extends AlbumDao {
  _$AlbumDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _albumEntityInsertionAdapter = InsertionAdapter(
            database,
            'album',
            (AlbumEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'thumbnailPath': item.thumbnailPath,
                  'path': item.path,
                  'numberOfItems': item.numberOfItems,
                  'albumType': item.albumType
                }),
        _albumEntityUpdateAdapter = UpdateAdapter(
            database,
            'album',
            ['id'],
            (AlbumEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'thumbnailPath': item.thumbnailPath,
                  'path': item.path,
                  'numberOfItems': item.numberOfItems,
                  'albumType': item.albumType
                }),
        _albumEntityDeletionAdapter = DeletionAdapter(
            database,
            'album',
            ['id'],
            (AlbumEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'thumbnailPath': item.thumbnailPath,
                  'path': item.path,
                  'numberOfItems': item.numberOfItems,
                  'albumType': item.albumType
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AlbumEntity> _albumEntityInsertionAdapter;

  final UpdateAdapter<AlbumEntity> _albumEntityUpdateAdapter;

  final DeletionAdapter<AlbumEntity> _albumEntityDeletionAdapter;

  @override
  Future<List<MediaEntity>> findAllMediaByAlbumName(String albumName) async {
    return _queryAdapter.queryList(
        'SELECT media.* FROM media   INNER JOIN media_album ON media.id = media_album.mediaId   INNER JOIN album ON media_album.albumId = album.id   WHERE album.title = ?1',
        mapper: (Map<String, Object?> row) => MediaEntity(id: row['id'] as String, name: row['name'] as String, path: row['path'] as String, dateAddedTimestamp: row['dateAddedTimestamp'] as int, dateModifiedTimestamp: row['dateModifiedTimestamp'] as int?, type: row['type'] as String, duration: row['duration'] as String?, isFavorite: (row['isFavorite'] as int) != 0),
        arguments: [albumName]);
  }

  @override
  Future<int?> checkAlbumEmpty(String albumTitle) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM album WHERE title = ?1 AND id IN (SELECT albumId FROM media_album)',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [albumTitle]);
  }

  @override
  Future<int?> checkExistMedia(
    String albumTitle,
    String mediaId,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM media_album    WHERE mediaId = ?2    AND albumId = (SELECT id FROM album WHERE title = ?1)',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [albumTitle, mediaId]);
  }

  @override
  Future<void> addMediaToExistAlbum(
    String title,
    String mediaId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'INSERT INTO media_album (mediaId, albumId)   VALUES (?2, (SELECT id FROM album WHERE title = ?1))',
        arguments: [title, mediaId]);
  }

  @override
  Future<List<AlbumEntity>> findAllAlbumEntity() async {
    return _queryAdapter.queryList('SELECT * FROM album',
        mapper: (Map<String, Object?> row) => AlbumEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            thumbnailPath: row['thumbnailPath'] as String,
            path: row['path'] as String,
            numberOfItems: row['numberOfItems'] as int,
            albumType: row['albumType'] as String));
  }

  @override
  Future<List<AlbumEntity>> getAllAlbum(
    int offset,
    int limit,
  ) async {
    return _queryAdapter.queryList('SELECT * FROM album LIMIT ?2 OFFSET ?1',
        mapper: (Map<String, Object?> row) => AlbumEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            thumbnailPath: row['thumbnailPath'] as String,
            path: row['path'] as String,
            numberOfItems: row['numberOfItems'] as int,
            albumType: row['albumType'] as String),
        arguments: [offset, limit]);
  }

  @override
  Future<AlbumEntity?> findAlbumByTitle(String title) async {
    return _queryAdapter.query('SELECT * FROM album WHERE title = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => AlbumEntity(
            id: row['id'] as int,
            title: row['title'] as String,
            thumbnailPath: row['thumbnailPath'] as String,
            path: row['path'] as String,
            numberOfItems: row['numberOfItems'] as int,
            albumType: row['albumType'] as String),
        arguments: [title]);
  }

  @override
  Future<void> insertAlbum(AlbumEntity album) async {
    await _albumEntityInsertionAdapter.insert(album, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAlbum(AlbumEntity album) async {
    await _albumEntityUpdateAdapter.update(album, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAlbum(AlbumEntity album) async {
    await _albumEntityDeletionAdapter.delete(album);
  }
}

class _$MediaDao extends MediaDao {
  _$MediaDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mediaEntityInsertionAdapter = InsertionAdapter(
            database,
            'media',
            (MediaEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'path': item.path,
                  'dateAddedTimestamp': item.dateAddedTimestamp,
                  'dateModifiedTimestamp': item.dateModifiedTimestamp,
                  'type': item.type,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'duration': item.duration
                }),
        _mediaEntityUpdateAdapter = UpdateAdapter(
            database,
            'media',
            ['id'],
            (MediaEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'path': item.path,
                  'dateAddedTimestamp': item.dateAddedTimestamp,
                  'dateModifiedTimestamp': item.dateModifiedTimestamp,
                  'type': item.type,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'duration': item.duration
                }),
        _mediaEntityDeletionAdapter = DeletionAdapter(
            database,
            'media',
            ['id'],
            (MediaEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
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

  final InsertionAdapter<MediaEntity> _mediaEntityInsertionAdapter;

  final UpdateAdapter<MediaEntity> _mediaEntityUpdateAdapter;

  final DeletionAdapter<MediaEntity> _mediaEntityDeletionAdapter;

  @override
  Future<List<MediaEntity>> findAllMedia() async {
    return _queryAdapter.queryList('SELECT * FROM media',
        mapper: (Map<String, Object?> row) => MediaEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            path: row['path'] as String,
            dateAddedTimestamp: row['dateAddedTimestamp'] as int,
            dateModifiedTimestamp: row['dateModifiedTimestamp'] as int?,
            type: row['type'] as String,
            duration: row['duration'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0));
  }

  @override
  Future<MediaEntity?> findMediaById(String id) async {
    return _queryAdapter.query('SELECT * FROM media WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MediaEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            path: row['path'] as String,
            dateAddedTimestamp: row['dateAddedTimestamp'] as int,
            dateModifiedTimestamp: row['dateModifiedTimestamp'] as int?,
            type: row['type'] as String,
            duration: row['duration'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<AlbumEntity>> findAlbum(String mediaId) async {
    return _queryAdapter.queryList(
        'SELECT album.* FROM album    INNER JOIN media_album ON album.id = media_album.albumId   WHERE media_album.mediaId = ?1',
        mapper: (Map<String, Object?> row) => AlbumEntity(id: row['id'] as int, title: row['title'] as String, thumbnailPath: row['thumbnailPath'] as String, path: row['path'] as String, numberOfItems: row['numberOfItems'] as int, albumType: row['albumType'] as String),
        arguments: [mediaId]);
  }

  @override
  Future<List<MediaEntity>> findAllMediaByTitleAlbum(String title) async {
    return _queryAdapter.queryList(
        'SELECT media.*    FROM media    INNER JOIN media_album ON media.id = media_album.mediaId   INNER JOIN album ON album.id = media_album.albumId   WHERE album.title = ?1',
        mapper: (Map<String, Object?> row) => MediaEntity(id: row['id'] as String, name: row['name'] as String, path: row['path'] as String, dateAddedTimestamp: row['dateAddedTimestamp'] as int, dateModifiedTimestamp: row['dateModifiedTimestamp'] as int?, type: row['type'] as String, duration: row['duration'] as String?, isFavorite: (row['isFavorite'] as int) != 0),
        arguments: [title]);
  }

  @override
  Future<bool?> checkExistAlbum(String name) async {
    return _queryAdapter.query(
        'SELECT EXISTS(SELECT 1 FROM album WHERE title = ?1)',
        mapper: (Map<String, Object?> row) => (row.values.first as int) != 0,
        arguments: [name]);
  }

  @override
  Future<void> insertMedia(MediaEntity media) async {
    await _mediaEntityInsertionAdapter.insert(media, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMedia(MediaEntity media) async {
    await _mediaEntityUpdateAdapter.update(media, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMedia(MediaEntity media) async {
    await _mediaEntityDeletionAdapter.delete(media);
  }
}

class _$TagDao extends TagDao {
  _$TagDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _tagEntityDeletionAdapter = DeletionAdapter(
            database,
            'tag',
            ['id'],
            (TagEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'color': item.color,
                  'mediaId': item.mediaId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final DeletionAdapter<TagEntity> _tagEntityDeletionAdapter;

  @override
  Future<List<TagEntity>> findAllTags() async {
    return _queryAdapter.queryList('SELECT * FROM tag',
        mapper: (Map<String, Object?> row) => TagEntity(
            id: row['id'] as int,
            name: row['name'] as String,
            color: row['color'] as String,
            mediaId: row['mediaId'] as int));
  }

  @override
  Future<List<TagEntity>> findAllTagsByMediaId(String mediaId) async {
    return _queryAdapter.queryList('SELECT * FROM tag WHERE mediaId = ?1',
        mapper: (Map<String, Object?> row) => TagEntity(
            id: row['id'] as int,
            name: row['name'] as String,
            color: row['color'] as String,
            mediaId: row['mediaId'] as int),
        arguments: [mediaId]);
  }

  @override
  Future<void> deleteTag(TagEntity tag) async {
    await _tagEntityDeletionAdapter.delete(tag);
  }
}
