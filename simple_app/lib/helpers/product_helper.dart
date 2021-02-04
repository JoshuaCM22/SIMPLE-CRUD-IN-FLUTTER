import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String productTable = 'productTable';
final String idColumn = 'idColumn';
final String productNameColumn = 'productNameColumn';
final String unitColumn = 'unitColumn';
final String priceColumn = 'priceColumn';
final String dateOfExpiryColumn = 'dateOfExpiryColumn';
final String availableInventoryColumn = 'availableInventoryColumn';
final String imageColumn = 'imageColumn';

class ProductHelper {
  static final ProductHelper _instance = ProductHelper.internal();
  factory ProductHelper() => _instance;
  ProductHelper.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'product.db');
    return await openDatabase(path, version: 1,
        onCreate: (db, newerVersion) async {
      await db.execute('CREATE TABLE $productTable('
          '$idColumn INTEGER PRIMARY KEY,'
          '$productNameColumn TEXT,'
          '$unitColumn TEXT,'
          '$priceColumn REAL,'
          '$dateOfExpiryColumn TEXT,'
          '$availableInventoryColumn INTEGER,'
          '$imageColumn TEXT)');
    });
  }

  Future<Products> saveProduct(Products product) async {
    var dbProduct = await db;
    product.id = await dbProduct.insert(productTable, product.toMap());
    return product;
  }

  Future<Products> getProduct(int id) async {
    var dbProduct = await db;
    List<Map> maps = await dbProduct.query(productTable,
        columns: [
          idColumn,
          productNameColumn,
          unitColumn,
          priceColumn,
          dateOfExpiryColumn,
          availableInventoryColumn,
          imageColumn
        ],
        where: '$idColumn = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Products.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteProduct(int id) async {
    var dbProduct = await db;
    return await dbProduct
        .delete(productTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updateProduct(Products product) async {
    var dbProduct = await db;
    return await dbProduct.update(productTable, product.toMap(),
        where: '$idColumn = ?', whereArgs: [product.id]);
  }

  Future<List> getAllProducts() async {
    var dbProduct = await db;
    List listMap = await dbProduct.rawQuery('SELECT * FROM $productTable');
    var listProduct = <Products>[];
    for (Map m in listMap) {
      listProduct.add(Products.fromMap(m));
    }
    return listProduct;
  }

  Future<int> getNumber() async {
    var dbProduct = await db;
    return Sqflite.firstIntValue(
        await dbProduct.rawQuery('SELECT COUNT(*) FROM $productTable'));
  }

  Future close() async {
    var dbProduct = await db;
    dbProduct.close();
  }
}

class Products {
  int id;
  String productName;
  String unit;
  double price;
  String dateOfExpiry;
  int availableInventory;
  String image;

  Products();

  Products.fromMap(Map map) {
    id = map[idColumn];
    productName = map[productNameColumn];
    unit = map[unitColumn];
    price = map[priceColumn];
    dateOfExpiry = map[dateOfExpiryColumn];
    availableInventory = map[availableInventoryColumn];
    image = map[imageColumn];
  }

  Map toMap() {
    var map = <String, dynamic>{
      productNameColumn: productName,
      unitColumn: unit,
      priceColumn: price,
      dateOfExpiryColumn: dateOfExpiry,
      availableInventoryColumn: availableInventory,
      imageColumn: image
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Products('
        'id: $id,'
        'productName : $productName, '
        'unit: $unit, '
        'price: $price, '
        'dateOfExpiry: $dateOfExpiry, '
        'availableInventory: $availableInventory, '
        'image: $image)';
  }
}
