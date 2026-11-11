import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/produk.dart';
import '../helpers/database_helper.dart';
import 'form_produk_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _kategoriTerpilih = 0;
  String _keywordPencarian = '';

  final List<String> _kategoriList = [
    'Semua',
    'Makanan',
    'Minuman',
    'Snack',
    'Dessert',
  ];

  // Mengambil data produk langsung dari database SQLite menggunakan getAllProduk()
  Future<List<Produk>> _ambilDataProduk() async {
    return await DatabaseHelper.instance.getAllProduk();
  }

  String _formatRupiah(double nominal) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(nominal);
  }

  Widget _buildBadgeStok(int stok) {
    late Color warnaLatar;
    late Color warnaTeks;
    late String label;

    if (stok <= 0) {
      warnaLatar = Colors.red.shade100;
      warnaTeks = Colors.red.shade900;
      label = 'Habis';
    } else if (stok <= 5) {
      warnaLatar = Colors.amber.shade100;
      warnaTeks = Colors.amber.shade900;
      label = 'Sisa $stok';
    } else {
      warnaLatar = Colors.green.shade100;
      warnaTeks = Colors.green.shade900;
      label = 'Stok $stok';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: warnaTeks,
        ),
      ),
    );
  }

  Widget _buildKartuProduk(Produk produk) {
    return InkWell(
      onTap: () async {
        // Navigasi ke Form Produk untuk Edit Data
        final hasil = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormProdukPage(produk: produk),
          ),
        );

        // Jika berhasil disimpan/diperbarui, muat ulang tampilan
        if (hasil == true) {
          setState(() {});
        }
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto produk dan badge promo.
            Stack(
              children: [
                Image.network(
                  produk.gambarUrl.isNotEmpty
                      ? produk.gambarUrl
                      : 'https://via.placeholder.com/150',
                  height: 125,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Container(
                      height: 125,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 125,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 36,
                      ),
                    );
                  },
                ),
                if (produk.diskonPersen > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PROMO ${produk.diskonPersen}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Informasi nama, stok, dan harga produk.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildBadgeStok(produk.stok),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatRupiah(produk.hargaJual),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: produk.stok <= 0
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${produk.nama} dipilih.',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                          borderRadius: BorderRadius.circular(20),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: produk.stok <= 0
                                ? Colors.grey.shade300
                                : const Color(0xFF1E3A8A),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.point_of_sale,
              color: Colors.amber,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'SmartKasir',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi Penjualan',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Belum ada notifikasi.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // BLOK 1: Ringkasan penjualan.
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Penjualan Hari Ini',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(845000),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '34 Transaksi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BLOK PENCARIAN & TOMBOL TAMBAH PRODUK (+)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _keywordPencarian = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    // Buka Form Produk untuk Tambah Data Baru
                    final hasil = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormProdukPage(),
                      ),
                    );

                    if (hasil == true) {
                      setState(() {});
                    }
                  },
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // BLOK 2: Filter kategori horizontal.
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _kategoriList.length,
              itemBuilder: (context, index) {
                final isSelected = _kategoriTerpilih == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_kategoriList[index]),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1E3A8A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (value) {
                      setState(() {
                        _kategoriTerpilih = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // BLOK 3: Grid katalog produk dengan FutureBuilder (SQLite)
          Expanded(
            child: FutureBuilder<List<Produk>>(
              future: _ambilDataProduk(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada produk di database'),
                  );
                }

                // Ambil data dari snapshot
                List<Produk> dataProduk = snapshot.data!;

                // Filter berdasarkan kategori yang dipilih
                if (_kategoriTerpilih != 0) {
                  final kategori = _kategoriList[_kategoriTerpilih];
                  dataProduk = dataProduk
                      .where((produk) => produk.kategori == kategori)
                      .toList();
                }

                // Filter berdasarkan kata kunci pencarian
                if (_keywordPencarian.isNotEmpty) {
                  dataProduk = dataProduk
                      .where((produk) => produk.nama
                          .toLowerCase()
                          .contains(_keywordPencarian.toLowerCase()))
                      .toList();
                }

                if (dataProduk.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada produk yang ditemukan'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.74,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: dataProduk.length,
                  itemBuilder: (context, index) {
                    final produk = dataProduk[index];
                    return _buildKartuProduk(produk);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}