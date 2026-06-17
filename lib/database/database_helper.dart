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
    // অ্যাডভান্সড মেটাল ও এক্সচেঞ্জ সাপোর্ট যুক্ত করায় ভার্সন ৩ করা হলো
    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
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

    // অ্যাডভান্সড জুয়েলারি আইটেম টেবিল (সোনা/রূপা এবং এক্সচেঞ্জ ডাটা সহ)
    await _createJewelryItemsTable(db);
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
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // পুরাতন টেবিল ড্রপ করে নতুন স্ট্রাকচারে মেটাল ও এক্সচেঞ্জ ফিল্ড সহ তৈরি করা
      await db.execute('DROP TABLE IF EXISTS jewelry_items');
      await _createJewelryItemsTable(db);
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
      );
    }).toList();
  }

  // কাস্টম অ্যাডভান্সড মেমো সার্চ (নাম, মোবাইল, ঠিকানা বা মেমো নাম্বার দিয়ে খোঁজা)
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
      );
    }).toList();
  }

  Future<int> deleteMemo(int id) async {
    final db = await instance.database;
    return await db.delete('m_memos', where: 'id = ?', whereArgs: [id]);
  }
}
