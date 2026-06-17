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
    // ডেটাবেজ ভার্সন ২ করা হলো যাতে নতুন টেবিলটি তৈরি হতে পারে
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
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

    // নতুন জুয়েলারি আইটেম (ইনভেন্টরি) টেবিল
    await db.execute('''
    CREATE TABLE jewelry_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      karat TEXT NOT NULL,
      vori REAL NOT NULL,
      ana REAL NOT NULL,
      rati REAL NOT NULL,
      point REAL NOT NULL,
      totalVori REAL NOT NULL,
      pricePerVori REAL NOT NULL,
      wastage REAL NOT NULL,
      makingCharge REAL NOT NULL,
      totalPrice REAL NOT NULL,
      stockQuantity INTEGER NOT NULL
    )
    ''');
  }

  // যদি অ্যাপ আগে থেকে ফোনে ইন্সটল থাকে তবে নতুন টেবিল যোগ করার জন্য অন-আপগ্রেড লজিক
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE jewelry_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        karat TEXT NOT NULL,
        vori REAL NOT NULL,
        ana REAL NOT NULL,
        rati REAL NOT NULL,
        point REAL NOT NULL,
        totalVori REAL NOT NULL,
        pricePerVori REAL NOT NULL,
        wastage REAL NOT NULL,
        makingCharge REAL NOT NULL,
        totalPrice REAL NOT NULL,
        stockQuantity INTEGER NOT NULL
      )
      ''');
    }
  }

  // ==================== ಜುয়েলারি আইটেম (Inventory) মেথডসমূহ ====================

  // ১. নতুন প্রোডাক্ট ইনভেন্টরিতে যোগ করা
  Future<int> insertJewelryItem(JewelryItem item) async {
    final db = await instance.database;
    return await db.insert('jewelry_items', item.toMap());
  }

  // ২. ইনভেন্টরি থেকে সব প্রোডাক্টের তালিকা নিয়ে আসা
  Future<List<JewelryItem>> fetchJewelryItems() async {
    final db = await instance.database;
    final result = await db.query('jewelry_items', orderBy: 'id DESC');
    return result.map((json) => JewelryItem.fromMap(json)).toList();
  }

  // ৩. প্রোডাক্টের স্টক আপডেট করা (যেমন বিক্রির পর স্টক কমানো বা নতুন স্টক বাড়ানো)
  Future<int> updateJewelryItem(JewelryItem item) async {
    final db = await instance.database;
    return await db.update(
      'jewelry_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // ৪. ইনভেন্টরি থেকে কোনো প্রোডাক্ট ডিলিট করা
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

  Future<int> deleteMemo(int id) async {
    final db = await instance.database;
    return await db.delete('m_memos', where: 'id = ?', whereArgs: [id]);
  }
}
