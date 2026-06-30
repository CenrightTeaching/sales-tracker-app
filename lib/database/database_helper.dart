import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_tracker/models/sale.dart';
import 'package:sales_tracker/models/item.dart';

class DatabaseHelper {
  static const String _dbName = 'sales_tracker.db';
  static const int _dbVersion = 1;

  static const String _tableItems = 'items';
  static const String _tableSales = 'sales';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableSales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemName TEXT NOT NULL,
        units INTEGER NOT NULL,
        value REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> initDb() async {
    await database;
  }

  // Item operations
  Future<int> addItem(Item item) async {
    Database db = await database;
    return await db.insert(_tableItems, item.toMap());
  }

  Future<List<Item>> getAllItems() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(_tableItems);
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<int> updateItem(Item item) async {
    Database db = await database;
    return await db.update(
      _tableItems,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete(
      _tableItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sale operations
  Future<int> addSale(Sale sale) async {
    Database db = await database;
    return await db.insert(_tableSales, sale.toMap());
  }

  Future<List<Sale>> getSalesByDate(DateTime date) async {
    Database db = await database;
    String dateString = date.toIso8601String().split('T')[0];
    List<Map<String, dynamic>> maps = await db.query(
      _tableSales,
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
    );
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  Future<List<Sale>> getAllSales() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(_tableSales);
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  Future<int> updateSale(Sale sale) async {
    Database db = await database;
    return await db.update(
      _tableSales,
      sale.toMap(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );
  }

  Future<int> deleteSale(int id) async {
    Database db = await database;
    return await db.delete(
      _tableSales,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getDailySalesByItem(DateTime date) async {
    List<Sale> sales = await getSalesByDate(date);
    Map<String, double> totals = {};
    for (var sale in sales) {
      double revenue = sale.totalRevenue;
      totals[sale.itemName] = (totals[sale.itemName] ?? 0) + revenue;
    }
    return totals;
  }
}
