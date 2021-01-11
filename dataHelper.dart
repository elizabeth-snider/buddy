import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'transactionCLASS.dart';

class DBHelper {
  static Database _db;
  static const String ID = 'id';
  static const String VAL = 'val';
  static const String CATEGORY = 'category';
  static const String TABLE = 'Transaction_table';
  static const String DB_NAME = 'transaction1.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $CATEGORY TEXT, $VAL REAL)");
  }

  Future<TransactionClass> save(TransactionClass transaction) async {
    var dbClient = await db;
    transaction.id = await dbClient.insert(TABLE, transaction.toMap());
    return transaction;
  }

  Future<List<TransactionClass>> getTransactions() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, CATEGORY, VAL]);
    //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<TransactionClass> em = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        em.add(TransactionClass.fromMap(maps[i]));
      }
    }
    return em;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> update(TransactionClass em) async {
    var dbClient = await db;
    return await dbClient
        .update(TABLE, em.toMap(), where: '$ID = ?', whereArgs: [em.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future deleteAll() async {
    var dbClient = await db;
    dbClient.delete('$TABLE');
  }
}
