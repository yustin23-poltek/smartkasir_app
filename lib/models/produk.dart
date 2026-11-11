// Blueprint / Struktur Data (Model) entitas produk kasir ritel SmartKasir
class Produk {
  // --- DEKLARASI VARIABEL ATRIBUT MODEL (PROPERTIES) ---
  final int? id;              // ID unik produk (Nullable karena digenerate otomatis oleh SQLite via AUTOINCREMENT)[cite: 4]
  final String kodeProduk;    // Kode unik produk / SKU / Barcode kasir[cite: 4]
  final String nama;          // Nama barang dagangan[cite: 4]
  final String kategori;      // Kelompok produk: Makanan / Minuman / Snack[cite: 4]
  final double hargaBeli;     // Harga beli modal / HPP[cite: 4]
  final double hargaJual;     // Harga jual kasir kepada konsumen (sebelumnya bernama 'harga')[cite: 4]
  final int stok;             // Sisa kuantitas fisik barang di toko[cite: 4]
  final String gambarUrl;     // URL foto atau path lokal gambar produk[cite: 4]
  final int diskonPersen;     // Persentase promo diskon kasir (default 0)[cite: 4]

  // Konstruktor konstan dengan parameter wajib (required) dan opsional (default)
  const Produk({
    this.id,
    required this.kodeProduk,
    required this.nama,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.gambarUrl,
    this.diskonPersen = 0,
  });

  // --- METODE SERIALISASI (DART OBJECT -> SQLITE ROW MAP) ---
  // Mengonversi objek class Produk menjadi struktur Map<String, dynamic> untuk disimpan ke tabel SQLite[cite: 4]

  Map<String, dynamic> toMap() {
    return {
    if (id != null) 'id': id,
    'kode_produk': kodeProduk,
    'nama_produk': nama,
    'kategori': kategori,
    'harga_beli': hargaBeli,
    'harga_jual': hargaJual,
    'stok': stok,
    'gambar_path': gambarUrl,
    'diskon_persen': diskonPersen,
  };
}


  // --- METODE DESERIALISASI (SQLITE ROW MAP -> DART OBJECT) ---
  // Membaca baris data (Map) hasil kueri SELECT dari tabel SQLite dan mengubahnya kembali menjadi objek Produk[cite: 5]
  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'] as int?,
      kodeProduk: map['kode_produk'] as String,
      nama: map['nama_produk'] as String,
      kategori: map['kategori'] as String,
      hargaBeli: (map['harga_beli'] as num).toDouble(),
      hargaJual: (map['harga_jual'] as num).toDouble(),
      stok: map['stok'] as int,
      gambarUrl: map['gambar_path'] as String? ?? '',
      diskonPersen: map['diskon_persen'] as int? ?? 0,
    );
  }
}

// --- DATA SEEDING AWAL PRODUK BAWAAN SQLITE ---
// Daftar produk awal yang akan dimasukkan otomatis saat database pertama kali dibuat[cite: 4, 5, 7]
final List<Produk> produkAwalSQLite = [
  const Produk(
    kodeProduk: 'PRD-001',
    nama: 'Kopi Susu Gula Aren 250ml',
    kategori: 'Minuman',
    hargaBeli: 10000,
    hargaJual: 18000,
    stok: 24,
    gambarUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500',
    diskonPersen: 20,
  ),
  const Produk(
    kodeProduk: 'PRD-002',
    nama: 'Roti Bakar Cokelat Keju',
    kategori: 'Makanan',
    hargaBeli: 8000,
    hargaJual: 15000,
    stok: 5,
    gambarUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
  ),
  const Produk(
    kodeProduk: 'PRD-003',
    nama: 'Matcha Latte',
    kategori: 'Minuman',
    hargaBeli: 12000,
    hargaJual: 22000,
    stok: 0,
    gambarUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500',
  ),
  const Produk(
    kodeProduk: 'PRD-004',
    nama: 'Nasi Goreng Banjar Spesial',
    kategori: 'Makanan',
    hargaBeli: 15000,
    hargaJual: 25000,
    stok: 12,
    gambarUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
    diskonPersen: 10,
  ),
  const Produk(
    kodeProduk: 'PRD-005',
    nama: 'Kentang Goreng Crispy',
    kategori: 'Snack',
    hargaBeli: 6000,
    hargaJual: 12000,
    stok: 18,
    gambarUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=600&q=80',
  ),
  const Produk(
    kodeProduk: 'PRD-006',
    nama: 'Ubi Goreng Crispy',
    kategori: 'Snack',
    hargaBeli: 6000,
    hargaJual: 12000,
    stok: 18,
    gambarUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500',
  ),
  const Produk(
    kodeProduk: 'PRD-007',
    nama: 'Air Mineral Botol 600ml',
    kategori: 'Minuman',
    hargaBeli: 3000,
    hargaJual: 5000,
    stok: 40,
    gambarUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=500',
  ),
];