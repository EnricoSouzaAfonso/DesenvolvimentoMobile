import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = '';

    if (Platform.isWindows || Platform.isLinux) {
      final databaseFactory = databaseFactoryFfi;
      final caminhoBanco = await databaseFactory.getDatabasesPath();
      path = join(caminhoBanco, 'banco_pets.db');
    } else {
      String caminhoBanco = await getDatabasesPath();
      path = join(caminhoBanco, 'banco_pets.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE caes (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            nome TEXT, 
            idade INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> inserir(Map<String, dynamic> dados) async {
    final db = await database;
    return await db.insert('caes', dados);
  }

  static Future<List<Map<String, dynamic>>> listar() async {
    final db = await database;
    return await db.query('caes');
  }

  static Future<int> atualizar(int id, Map<String, dynamic> dados) async {
    final db = await database;
    return await db.update('caes', dados, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> apagar(int id) async {
    final db = await database;
    return await db.delete('caes', where: 'id = ?', whereArgs: [id]);
  }
}