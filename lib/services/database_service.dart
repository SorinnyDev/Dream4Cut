import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/goal.dart';

import '../models/log.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dream4cut.db');
    return await openDatabase(
      path,
      version: 4, // emojiTag 필드 추가
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS logs');
      await db.execute('DROP TABLE IF EXISTS goals');
      await _onCreate(db, newVersion);
    } else if (oldVersion < 3) {
      // Version 3: timeCapsuleMessage 필드 추가
      await db.execute('ALTER TABLE goals ADD COLUMN timeCapsuleMessage TEXT');
    }
    if (oldVersion < 4) {
      // Version 4: emojiTag 필드 추가
      await db.execute('ALTER TABLE goals ADD COLUMN emojiTag TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals(
        id TEXT PRIMARY KEY,
        title TEXT,
        backgroundTheme TEXT,
        totalCount INTEGER,
        createdAt TEXT,
        updatedAt TEXT,
        status TEXT,
        frameIndex INTEGER,
        slotIndex INTEGER,
        completedAt TEXT,
        timeCapsuleMessage TEXT,
        emojiTag TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE logs(
        id TEXT PRIMARY KEY,
        goalId TEXT,
        content TEXT,
        actionDate TEXT,
        createdAt TEXT,
        "index" INTEGER,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');
  }

  // Goal CRUD
  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert(
      'goals',
      goal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromJson(maps[i]));
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update(
      'goals',
      goal.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // Log CRUD
  Future<void> insertLog(Log log) async {
    final db = await database;
    await db.insert(
      'logs',
      log.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Log>> getLogsByGoalId(String goalId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'logs',
      where: 'goalId = ?',
      whereArgs: [goalId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Log.fromJson(maps[i]));
  }

  Future<void> deleteLog(String id) async {
    final db = await database;
    await db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }
}
