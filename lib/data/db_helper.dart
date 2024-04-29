import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photoapp/data/app_database.dart';
import 'package:photoapp/utils/logger.dart';

class DBHelper {
  static const String databaseName = 'app_database.db';
  static AppDatabase? _instance;

  // Private constructor to prevent instantiation
  DBHelper._();

  // Method to obtain or create the singleton instance of AppDatabase
  static Future<AppDatabase> getInstance() async {
    // Delete the existing database file
    await _deleteDatabaseFile();

    _instance ??= await $FloorAppDatabase.databaseBuilder(databaseName).build();
    return _instance!;
  }

  static Future<void> _deleteDatabaseFile() async {
    // Get the directory where the database file is stored
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = '${documentsDirectory.path}/$databaseName';

    if (await File(dbPath).exists()) {
      LoggingUtil.logDebug("Delete database file");
      LoggingUtil.logDebug("Database file path: $dbPath");
    }
  }
}