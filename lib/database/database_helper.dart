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
      version: 1,
      onCreate: _createDB,
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

    // Insert default settings
    await db.insert('settings', {'key': 'theme_mode', 'value': 'system'});
    await db.insert('settings', {'key': 'language', 'value': 'en'});
    await db.insert('settings', {'key': 'temperature_unit', 'value': 'celsius'});
    await db.insert('settings', {'key': 'notifications', 'value': 'true'});
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

  Future<void> addSearchHistory(String cityName, String country, int cityId) async {
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

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
