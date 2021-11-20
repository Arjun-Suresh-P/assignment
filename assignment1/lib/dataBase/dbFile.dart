
import 'package:assignment1/model/dataBaseModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
class InitDataBase {

  static final String productDataTable = "productDataTable";
  static final String cartTable = "cartTable";
  static final String id = 'id';
  static final String title = "title";
  static final String image = "image";
  static final String amount = 'amount';
  static final String rate = "rate ";
  static final String count = "count";
  InitDataBase._privateConstructor();
  static final InitDataBase inst = InitDataBase._privateConstructor();
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDatabase();
      return _database;
    }
  }
  Future<Database> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath.toString(), "assignment.db");
    return await openDatabase(path, version: 1, onCreate: onCreateDatabase);
  }

  onCreateDatabase(Database db, int version) async {
    String script =
        "CREATE TABLE $productDataTable($id TEXT PRIMARY KEY, $title TEXT,$image TEXT,$rate TEXT,$amount TEXT); CREATE TABLE $cartTable($id TEXT PRIMARY KEY,$title TEXT,$image TEXT,$count TEXT,$amount TEXT)";
    List<String> scripts = script.split(";");
    scripts.forEach((v) {
      if (v.isNotEmpty) {
        db.execute(v.trim());
      }
    });
  }
  Future<int> insertData(String tableName, Map<String, dynamic> row) async {
    Database? db = await inst.database;
    return await db!.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryData(
      String tableName, String columnId, String idValue) async {
    Database? db = await inst.database;
    return await db
    !.query(tableName, where: '$columnId = ?', whereArgs: ['$idValue']);
  }

  Future<List<Map<String, dynamic>>> queryAllData(String tableName) async {
    Database? db = await inst.database;
    return await db!.query(tableName);
  }

  Future<int> updateData(
      String tableName,
      String whereColumnId,
      Map<String, dynamic> updatingData,
      List<dynamic> whereCondition,
      ) async {
    Database? db = await inst.database;
    return await db!.update(tableName, updatingData,
        where:
        "$whereColumnId IN (${('?' * (whereCondition.length)).split('').join(',')})",
        whereArgs: whereCondition);
  }

  Future<int> updateSingleRowData(
      String tableName,
      String whereColumnId,
      Map<String, dynamic> updatingData,
      List<dynamic> whereCondition,
      ) async {
    Database? db = await inst.database;
    return await db!.update(tableName, updatingData,
        where: '$whereColumnId = ?', whereArgs: whereCondition);
  }

  Future<int> deleteData(String tableName, String columnId, String columnName,
      String idValue, String columnValue) async {
    Database? db = await inst.database;

    return await db!.delete(tableName,
        where: '$columnId = ? and $columnName = ?',
        whereArgs: ['$idValue', '$columnValue']);
  }

  Future<int> deleteTableData(
      String tableName, String columnId, String idValue) async {
    Database? db = await inst.database;

    return await db
    !.delete(tableName, where: '$columnId = ?', whereArgs: ['$idValue']);
  }

  Future<void> updateTask(dynamic Task,var database) async {
    var dataBaseModel = DataBaseModel();
    dataBaseModel.id = Task['id'].toString();
    dataBaseModel.title = Task['title'].toString();
    dataBaseModel.image =Task['image'].toString();
    dataBaseModel.rate =Task['rate'].toString();
    await database.update(
      InitDataBase.productDataTable,
      dataBaseModel.toMap(),
      where: "id = ?",
      whereArgs: [Task['id']],
    );
  }

}