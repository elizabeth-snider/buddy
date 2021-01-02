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
      join(await getDatabasesPath(), 'transaction_history.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transaction_table(
            category TEXT, val TEXT
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
      INSERT INTO transaction_table (
        category, val
      ) VALUES (?, ?)
      ''', [newTransaction.category, newTransaction.val]
    );
    return res;
  }

  Future<dynamic> getCat() async{
    final db = await database;
    var res = await db.query("transaction_table");
    if(res.length == 0){
      return null;
    } else{
      var resMap = res[0];
      return resMap.isNotEmpty ? resMap : Null;
    }
  }
}


