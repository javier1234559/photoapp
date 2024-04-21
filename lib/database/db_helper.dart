import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photoapp/database/app_database.dart';

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

    print(dbPath);

    if (await File(dbPath).exists()) {
      print("Delete database file");
      print(dbPath);
    }

  }
}
