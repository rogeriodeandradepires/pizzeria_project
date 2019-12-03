import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "local.db";
  static final _databaseVersion = 1;

  static final favoritesTable = 'favorites';
  static final cartTable = 'cart';
  static final cartItemsTable = 'cartItems';

  static final columnId = '_id';
  static final columncartItemsId = 'cartItemsId';
  static final columnCategory = 'category';
  static final columnCategoryName = 'categoryName';
  static final columnIsLiked = 'isUserLiked';
  static final columnUserId = 'userId';
  static final columnProductId = 'productId';
  static final columnProduct2Id = 'product2Id';
  static final columnPizzaEdgeId = 'pizzaEdgeId';
  static final columnDateRegister = 'dateRegister';
  static final columnCartId = 'cartId';
  static final columnProductAmount = 'productAmount';
  static final columnProductObservations = 'productObservations';
  static final columnProductSize = 'productSize';
  static final columnIsTwoFlavoredPizza = 'isTwoFlavoredPizza';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $favoritesTable (
            $columnId TEXT PRIMARY KEY,
            $columnCategory TEXT NOT NULL,
            $columnCategoryName TEXT NOT NULL,
            $columnUserId TEXT NOT NULL,
            $columnProductId TEXT NOT NULL,
            $columnIsLiked INTEGER NOT NULL DEFAULT 0
          )
          ''');

    await db.execute('''
          CREATE TABLE $cartTable (
            $columnCartId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnUserId TEXT NOT NULL,
            $columnDateRegister TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $cartItemsTable (
            $columncartItemsId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnCartId INTEGER NOT NULL,
            $columnProductId TEXT NOT NULL,
            $columnProduct2Id TEXT,
            $columnProductObservations TEXT,
            $columnPizzaEdgeId TEXT,
            $columnProductSize TEXT,
            $columnIsTwoFlavoredPizza INTEGER NOT NULL DEFAULT 0,
            $columnProductAmount INTEGER NOT NULL DEFAULT 0
            
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row, String table) async {
//    'favorites', 'cart',  'cartItems'
    Database db = await instance.database;
    int retorno = await db.insert(table, row);
    print("$table $retorno");
    return retorno;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(favoritesTable);
  }

  Future<List<Map<String, dynamic>>> retrieveAllFavorites(String uid) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> records;
    if (uid!=null) {
      records = await db.rawQuery("SELECT * FROM $favoritesTable WHERE $columnUserId=\"$uid\" AND $columnIsLiked=\"1\"");
    }else{
      records = await db.rawQuery("SELECT * FROM $favoritesTable WHERE $columnIsLiked=\"1\"");
    }

    return records;
  }

  Future<Map<String, dynamic>> searchFavorite(String uid, String productId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> records = await db.rawQuery("SELECT * FROM $favoritesTable WHERE $columnUserId=\"$uid\" AND $columnProductId=\"$productId\"");

    var retorno = null;

    if (records.length!=0) {
      retorno = records.first;
    }

    return retorno;
  }

  Future<Map<String, dynamic>> searchCart(String uid) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> records = await db.rawQuery("SELECT * FROM $cartTable WHERE $columnUserId=\"$uid\"");

    var retorno = null;

    if (records.length!=0) {
      retorno = records.first;
    }

    return retorno;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $favoritesTable'));
  }

  Future<int> queryCartItemsRowCount(int cartId) async {
    Database db = await instance.database;
    int retorno = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $cartItemsTable WHERE cartId=\"$cartId\"'));
    print("$cartId, $retorno");
    return retorno;
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String id = row[columnId];
    return await db.update(favoritesTable, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(favoritesTable, where: '$columnId = ?', whereArgs: [id]);
  }
}