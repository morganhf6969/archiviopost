import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import '../models/saved_item.dart';

class SavedItemDao {
  static const String tableName = 'saved_items';

  // =========================
  // INSERT
  // =========================
  Future<void> insert(SavedItem item) async {
    final db = await AppDatabase.database;
    await db.insert(
      tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =========================
  // GET ALL
  // =========================
  Future<List<SavedItem>> getAll() async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      tableName,
      orderBy: 'created_at DESC',
    );
    return maps.map(SavedItem.fromMap).toList();
  }

  // =========================
  // GET BY CATEGORY
  // =========================
  Future<List<SavedItem>> getByCategory(String category) async {
    final db = await AppDatabase.database;

    final maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );

    return maps.map(SavedItem.fromMap).toList();
  }

  // =========================
  // GET UNCATEGORIZED (ALTRO)
  // =========================
  Future<List<SavedItem>> getUncategorized() async {
    final db = await AppDatabase.database;

    final maps = await db.query(
      tableName,
      where: 'category IS NULL OR category = ? OR category = ?',
      whereArgs: ['', 'Altro'],
      orderBy: 'created_at DESC',
    );

    return maps.map(SavedItem.fromMap).toList();
  }

  // =========================
  // DELETE
  // =========================
  Future<void> delete(int id) async {
    final db = await AppDatabase.database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // COUNT BY CATEGORY
  // =========================
  Future<int> countByCategory(String category) async {
    final db = await AppDatabase.database;

    if (category.toLowerCase() == 'altro') {
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM $tableName
        WHERE category IS NULL OR category = '' OR category = 'Altro'
      ''');
      return Sqflite.firstIntValue(result) ?? 0;
    }

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM $tableName
      WHERE category = ?
      ''',
      [category],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
