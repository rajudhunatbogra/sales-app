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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
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
  }

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
