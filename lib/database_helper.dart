import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            uid TEXT PRIMARY KEY,
            role TEXT
          )
        ''');
      },
    );
  }


  Future<void> insertUser(String uid, String role) async {
    final db = await database;

    await db.insert(
      'users',
      {
        'uid': uid,
        'role': role,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("USER SAVED → UID: $uid ROLE: $role");
  }


  Future<String?> getUserRole(String uid) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (result.isNotEmpty) {
      print("ROLE FOUND: ${result.first['role']}");
      return result.first['role'] as String;
    }

    print("NO ROLE FOUND IN DB");
    return null;
  }
  Future<void> printAllUsers() async {
    final db = await database;

    final result = await db.query('users');

    print("ALL USERS IN DB: $result");
  }


  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('users');
    print("DATABASE CLEARED");
  }
}