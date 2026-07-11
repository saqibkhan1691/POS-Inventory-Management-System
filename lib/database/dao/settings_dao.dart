import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../tables/settings_table.dart';
import '../../models/settings_model.dart';

/// ─────────────────────────────────────────────────────────────
///  SETTINGS DAO  –  lib/database/dao/settings_dao.dart
/// ─────────────────────────────────────────────────────────────
class SettingsDao {
  Future<Database> get _db => DbHelper.instance.database;

  // Get settings for a specific user
  Future<SettingsModel?> getByUserId(String userId) async {
    final db   = await _db;
    final maps = await db.query(
      SettingsTable.tableName,
      where: '${SettingsTable.userId} = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return maps.isEmpty ? null : SettingsModel.fromMap(maps.first);
  }

  // Insert default settings for new user
  Future<int> insertDefault(String userId) async {
    final db = await _db;
    final defaults = SettingsModel(
      userId:    userId,
      updatedAt: DateTime.now(),
    );
    return db.insert(
      SettingsTable.tableName,
      defaults.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Save / update settings for a user
  Future<void> save(SettingsModel settings) async {
    final db = await _db;
    final existing = await getByUserId(settings.userId);
    if (existing == null) {
      await db.insert(SettingsTable.tableName, settings.toMap());
    } else {
      await db.update(
        SettingsTable.tableName,
        settings.copyWith(updatedAt: DateTime.now()).toMap(),
        where: '${SettingsTable.userId} = ?',
        whereArgs: [settings.userId],
      );
    }
  }

  // Delete all settings for a user (on logout/account delete)
  Future<void> deleteByUserId(String userId) async {
    final db = await _db;
    await db.delete(
      SettingsTable.tableName,
      where: '${SettingsTable.userId} = ?',
      whereArgs: [userId],
    );
  }
}