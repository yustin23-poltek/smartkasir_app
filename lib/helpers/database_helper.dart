
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/produk.dart';

class DatabaseHelper {
  // 1. DESIGN PATTERN SINGLETON
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 2. GETTER DATABASE
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('smartkasir.db');
    return _database!;
  }

  // 3. INISIALISASI DATABASE ANDROID DAN WEB
  Future<Database> _initDB(String fileName) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;

      return await openDatabase(
        fileName,
        version: 1,
        onCreate: _createDB,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // 4. MEMBUAT TABEL DAN MEMASUKKAN DATA AWAL
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_produk TEXT UNIQUE,
        nama_produk TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli REAL NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        gambar_path TEXT,
        diskon_persen INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // Memasukkan data awal
    for (final produk in produkAwalSQLite) {
      await db.insert(
        'produk',
        produk.toMap(),
      );
    }
  }

  // 5. CREATE: MENAMBAHKAN PRODUK
  Future<int> insertProduk(Produk produk) async {
    final db = await instance.database;

    return await db.insert(
      'produk',
      produk.toMap(),
    );
  }

  // 6. READ: MENGAMBIL SEMUA PRODUK
  Future<List<Produk>> getAllProduk() async {
    final db = await instance.database;

    final result = await db.query(
      'produk',
      orderBy: 'id DESC',
    );

    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // 7. READ: FILTER BERDASARKAN KATEGORI
  Future<List<Produk>> getProdukByKategori(String kategori) async {
    if (kategori == 'Semua') {
      return await getAllProduk();
    }

    final db = await instance.database;

    final result = await db.query(
      'produk',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'id DESC',
    );

    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // 8. SEARCH: PENCARIAN NAMA DAN KODE PRODUK
  Future<List<Produk>> searchProduk(String keyword) async {
    final db = await instance.database;

    final result = await db.query(
      'produk',
      where: 'nama_produk LIKE ? OR kode_produk LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );

    return result.map((json) => Produk.fromMap(json)).toList();
  }

  // 9. UPDATE: MEMPERBARUI PRODUK
  Future<int> updateProduk(Produk produk) async {
    final db = await instance.database;

    return await db.update(
      'produk',
      produk.toMap(),
      where: 'id = ?',
      whereArgs: [produk.id],
    );
  }

  // 10. DELETE: MENGHAPUS PRODUK
  Future<int> deleteProduk(int id) async {
    final db = await instance.database;

    return await db.delete(
      'produk',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
