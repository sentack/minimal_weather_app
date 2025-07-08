import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/city_model.dart';
import '../models/search_history_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('weather_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Favorite Cities Table
    await db.execute('''
      CREATE TABLE favorite_cities (
        id INTEGER PRIMARY KEY,
        city_id INTEGER NOT NULL UNIQUE,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        added_at TEXT NOT NULL
      )
    ''');

    // Search History Table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city_name TEXT NOT NULL,
        country TEXT NOT NULL,
        city_id INTEGER NOT NULL,
        searched_at TEXT NOT NULL
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL
      )
    ''');

    // Insert default settings using INSERT OR IGNORE to prevent duplicates
    await _insertDefaultSettings(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the new weather display mode setting only if it doesn't exist
      await _insertSettingIfNotExists(db, 'weather_display_mode', 'simple');
    }
  }

  Future<void> _insertDefaultSettings(Database db) async {
    final defaultSettings = [
      {'key': 'theme_mode', 'value': 'system'},
      {'key': 'language', 'value': 'en'},
      {'key': 'temperature_unit', 'value': 'celsius'},
      {'key': 'notifications', 'value': 'true'},
      {'key': 'weather_display_mode', 'value': 'simple'},
    ];

    for (final setting in defaultSettings) {
      await db.insert(
        'settings',
        setting,
        conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore if already exists
      );
    }
  }

  Future<void> _insertSettingIfNotExists(
      Database db, String key, String value) async {
    final existing = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (existing.isEmpty) {
      await db.insert('settings', {'key': key, 'value': value});
    }
  }

  // Favorite Cities Methods
  Future<List<City>> getFavoriteCities() async {
    final db = await instance.database;
    final result = await db.query(
      'favorite_cities',
      orderBy: 'added_at DESC',
    );

    return result.map((json) => City.fromDatabaseJson(json)).toList();
  }

  Future<bool> isFavoriteCity(int cityId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorite_cities',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
    return result.isNotEmpty;
  }

  Future<void> addFavoriteCity(City city) async {
    final db = await instance.database;
    await db.insert(
      'favorite_cities',
      {
        'city_id': city.id,
        'name': city.name,
        'country': city.country,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavoriteCity(int cityId) async {
    final db = await instance.database;
    await db.delete(
      'favorite_cities',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
  }

  // Search History Methods
  Future<List<SearchHistory>> getSearchHistory() async {
    final db = await instance.database;
    final result = await db.query(
      'search_history',
      orderBy: 'searched_at DESC',
      limit: 20,
    );

    return result.map((json) => SearchHistory.fromJson(json)).toList();
  }

  Future<void> addSearchHistory(
      String cityName, String country, int cityId) async {
    final db = await instance.database;

    // Remove existing entry if exists
    await db.delete(
      'search_history',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );

    // Add new entry
    await db.insert('search_history', {
      'city_name': cityName,
      'country': country,
      'city_id': cityId,
      'searched_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearSearchHistory() async {
    final db = await instance.database;
    await db.delete('search_history');
  }

  // Settings Methods
  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method to initialize missing settings (useful for existing installations)
  Future<void> initializeMissingSettings() async {
    final db = await instance.database;

    final defaultSettings = [
      {'key': 'theme_mode', 'value': 'system'},
      {'key': 'language', 'value': 'en'},
      {'key': 'temperature_unit', 'value': 'celsius'},
      {'key': 'notifications', 'value': 'true'},
      {'key': 'weather_display_mode', 'value': 'simple'},
    ];

    for (final setting in defaultSettings) {
      final existing = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: [setting['key']],
      );

      if (existing.isEmpty) {
        await db.insert('settings', setting);
      }
    }
  }

  // Method to reset database (for debugging purposes)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'weather_app.db');

    await deleteDatabase(path);
    _database = null;

    // Reinitialize
    await database;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
