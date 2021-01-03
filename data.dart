import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:budget/models/transaction.dart';

class DBProvider{
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async{
    if(_database != null)
      return _database;

      _database = await initDB();
      return _database;
  }

  initDB() async{
    return await openDatabase(
      join(await getDatabasesPath(), 'transactions.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY, category TEXT, val TEXT
          )
        ''');
      },
      version: 1
    );
  }

  newTransaction(Transactions newTransaction) async{
    final db = await database;

    var res = await db.rawInsert(
      '''
      INSERT INTO transactions (
        id, category, val
      ) VALUES (?, ?, ?)
      ''', [newTransaction.id, newTransaction.category, newTransaction.val]
    );
    return res;
  }

  Future<dynamic> getCat() async{
    final db = await database;
    var res = await db.query("transactions");
    if(res.length == 0){
      return null;
    } else{
      var resMap = res[0];
      return resMap.isNotEmpty ? resMap : Null;
    }
  }
}


