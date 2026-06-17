import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/jewelry_item.dart';
import '../models/memo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jewelry_pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // প্রতিদিনের রেট টেবিল যুক্ত করায় ভার্সন ৪ করা হলো
    return await openDatabase(path, version: 4, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    // মেমো টেবিল
    await db.execute('''
    CREATE TABLE m_memos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      memoNo TEXT NOT NULL,
      customerName TEXT NOT NULL,
      customerPhone TEXT NOT NULL,
      customerAddress TEXT NOT NULL,
      date TEXT NOT NULL,
      subTotal REAL NOT NULL,
      discount REAL NOT NULL,
      grandTotal REAL NOT NULL,
      paidAmount REAL NOT NULL,
      dueAmount REAL NOT NULL,
      items TEXT NOT NULL
    )
    ''');

    // জুয়েলারি আইটেম টেবিল
    await _createJewelryItemsTable(db);
    
    // প্রতিদিনের রেট টেবিল
    await _createRatesTable(db);
  }

  Future _createJewelryItemsTable(Database db) async {
    await db.execute('''
    CREATE TABLE jewelry_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      itemType TEXT NOT NULL,
      karat TEXT NOT NULL,
      vori REAL NOT NULL,
      ana REAL NOT NULL,
      rati REAL NOT NULL,
      point REAL NOT NULL,
      gram REAL NOT NULL,
      totalVori REAL NOT NULL,
      pricePerVori REAL NOT NULL,
      wastage REAL NOT NULL,
      makingCharge REAL NOT NULL,
      totalPrice REAL NOT NULL,
      stockQuantity INTEGER NOT NULL,
      isExchange INTEGER NOT NULL,
      exchangeType TEXT NOT NULL,
      exchangeRate REAL NOT NULL,
      exchangeAmount REAL NOT NULL
    )
    ''');
  }

  Future _createRatesTable(Database db) async {
    await db.execute('''
    CREATE TABLE gold_rates (
      karat TEXT PRIMARY KEY,
      rate REAL NOT NULL
    )
    ''');
  }
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS jewelry_items');
      await _createJewelryItemsTable(db);
    }
    if (oldVersion < 4) {
      // ভার্সন ৪-এ আপগ্রেড করার সময় রেট টেবিল তৈরি করা হলো
      await _createRatesTable(db);
    }
  }

  // ==================== জুয়েলারি আইটেম মেথডসমূহ ====================

  Future<int> insertJewelryItem(JewelryItem item) async {
    final db = await instance.database;
    return await db.insert('jewelry_items', item.toMap());
  }

  Future<List<JewelryItem>> fetchJewelryItems() async {
    final db = await instance.database;
    final result = await db.query('jewelry_items', orderBy: 'id DESC');
    return result.map((json) => JewelryItem.fromMap(json)).toList();
  }

  Future<int> updateJewelryItem(JewelryItem item) async {
    final db = await instance.database;
    return await db.update(
      'jewelry_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteJewelryItem(int id) async {
    final db = await instance.database;
    return await db.delete('jewelry_items', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== প্রতিদিনের বাজুস রেট (Gold Rates) মেথডসমূহ ====================

  // ১. কোনো নির্দিষ্ট ক্যারেটের রেট সেভ বা আপডেট করা
  Future<void> saveRate(String karat, double rate) async {
    final db = await instance.database;
    await db.insert(
      'gold_rates',
      {'karat': karat, 'rate': rate},
      conflictAlgorithm: ConflictAlgorithm.replace, // রেট আগে থাকলে তা নতুন রেট দিয়ে রিপ্লেস হবে
    );
  }

  // ২. কোনো নির্দিষ্ট ক্যারেটের আজকের রেট কত তা তুলে আনা
  Future<double> getRateByKarat(String karat) async {
    final db = await instance.database;
    final maps = await db.query(
      'gold_rates',
      where: 'karat = ?',
      whereArgs: [karat],
    );
    if (maps.isNotEmpty) {
      return (maps.first['rate'] as num).toDouble();
    }
    return 0.0; // রেট সেট করা না থাকলে ডিফল্ট ০ টাকা দেখাবে
  }

  // ৩. সব ক্যারেটের রেটের তালিকা একসাথে ম্যাপ আকারে নিয়ে আসা
  Future<Map<String, double>> fetchAllRates() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('gold_rates');
    
    Map<String, double> ratesMap = {};
    for (var row in maps) {
      ratesMap[row['karat'] as String] = (row['rate'] as num).toDouble();
    }
    return ratesMap;
  }
  // ==================== মেমো (Memo) মেথডসমূহ ====================

  Future<int> insertMemo(Memo memo) async {
    final db = await instance.database;
    final itemsMapList = memo.items.map((item) => item.toMap()).toList();
    final itemsJson = jsonEncode(itemsMapList);

    final memoMap = memo.toMap();
    memoMap['items'] = itemsJson;
    return await db.insert('m_memos', memoMap);
  }

  Future<List<Memo>> fetchMemos() async {
    final db = await instance.database;
    final result = await db.query('m_memos', orderBy: 'id DESC');

    return result.map((json) {
      final itemsList = jsonDecode(json['items'] as String) as List;
      final items = itemsList.map((item) => JewelryItem.fromMap(item)).toList();

      return Memo(
        id: json['id'] as int?,
        memoNo: json['memoNo'] as String,
        customerName: json['customerName'] as String,
        customerPhone: json['customerPhone'] as String,
        customerAddress: json['customerAddress'] as String,
        date: json['date'] as String,
        subTotal: (json['subTotal'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        grandTotal: (json['grandTotal'] as num).toDouble(),
        paidAmount: (json['paidAmount'] as num).toDouble(),
        dueAmount: (json['dueAmount'] as num).toDouble(),
        items: items,
        exchangeItems: const [], // সামঞ্জস্য বজায় রাখার জন্য খালি লিস্ট
      );
    }).toList();
  }

  // কাস্টম অ্যাডভান্সড মেমো সার্চ
  Future<List<Memo>> searchMemos(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'm_memos',
      where: 'customerName LIKE ? OR customerPhone LIKE ? OR customerAddress LIKE ? OR memoNo LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'id DESC',
    );

    return result.map((json) {
      final itemsList = jsonDecode(json['items'] as String) as List;
      final items = itemsList.map((item) => JewelryItem.fromMap(item)).toList();
      return Memo(
        id: json['id'] as int?,
        memoNo: json['memoNo'] as String,
        customerName: json['customerName'] as String,
        customerPhone: json['customerPhone'] as String,
        customerAddress: json['customerAddress'] as String,
        date: json['date'] as String,
        subTotal: (json['subTotal'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        grandTotal: (json['grandTotal'] as num).toDouble(),
        paidAmount: (json['paidAmount'] as num).toDouble(),
        dueAmount: (json['dueAmount'] as num).toDouble(),
        items: items,
        exchangeItems: const [],
      );
    }).toList();
  }

  Future<int> deleteMemo(int id) async {
    final db = await instance.database;
    return await db.delete('m_memos', where: 'id = ?', whereArgs: [id]);
  }
}
