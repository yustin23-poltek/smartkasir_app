import 'package:flutter/material.dart';

import '../models/produk.dart';
import '../helpers/database_helper.dart';

class FormProdukPage extends StatefulWidget {
  final Produk? produk;

  const FormProdukPage({
    super.key,
    this.produk,
  });

  @override
  State<FormProdukPage> createState() => _FormProdukPageState();
}

class _FormProdukPageState extends State<FormProdukPage> {
  final _formKey = GlobalKey<FormState>();

  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokController = TextEditingController();
  final _gambarController = TextEditingController();
  final _diskonController = TextEditingController();

  String _kategori = 'Makanan';
  bool _isSaving = false;

  bool get _isEdit => widget.produk != null;

  @override
  void initState() {
    super.initState();

    final produk = widget.produk;

    if (produk != null) {
      _kodeController.text = produk.kodeProduk;
      _namaController.text = produk.nama;
      _hargaBeliController.text = produk.hargaBeli.toString();
      _hargaJualController.text = produk.hargaJual.toString();
      _stokController.text = produk.stok.toString();
      _gambarController.text = produk.gambarUrl;
      _diskonController.text = produk.diskonPersen.toString();
      _kategori = produk.kategori;
    } else {
      _diskonController.text = '0';
      _gambarController.text = '';
    }
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    _gambarController.dispose();
    _diskonController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi';
    }

    final number = double.tryParse(value);

    if (number == null || number < 0) {
      return 'Masukkan angka yang valid';
    }

    return null;
  }

  // Fungsi untuk memunculkan konfirmasi AlertDialog sebelum menghapus
  void _konfirmasiHapus() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${widget.produk?.nama}" dari database?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog (Batal)
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                // Eksekusi hapus dari database SQLite
                await DatabaseHelper.instance.deleteProduk(widget.produk!.id!);

                if (!mounted) return;
                Navigator.pop(context); // Tutup dialog konfirmasi
                Navigator.pop(context, true); // Kembali ke dashboard & refresh

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus dari database.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpanProduk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final produk = Produk(
        id: widget.produk?.id,
        kodeProduk: _kodeController.text.trim(),
        nama: _namaController.text.trim(),
        kategori: _kategori,
        hargaBeli: double.parse(_hargaBeliController.text),
        hargaJual: double.parse(_hargaJualController.text),
        stok: int.parse(_stokController.text),
        gambarUrl: _gambarController.text.trim(),
        diskonPersen: int.parse(_diskonController.text),
      );

      if (_isEdit) {
        await DatabaseHelper.instance.updateProduk(produk);
      } else {
        await DatabaseHelper.instance.insertProduk(produk);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Produk berhasil diperbarui'
                : 'Produk berhasil ditambahkan',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ?? _validateRequired,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                label: 'Kode Produk',
                controller: _kodeController,
                icon: Icons.qr_code,
              ),
              _buildField(
                label: 'Nama Produk',
                controller: _namaController,
                icon: Icons.inventory_2_outlined,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _kategori,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Makanan',
                      child: Text('Makanan'),
                    ),
                    DropdownMenuItem(
                      value: 'Minuman',
                      child: Text('Minuman'),
                    ),
                    DropdownMenuItem(
                      value: 'Snack',
                      child: Text('Snack'),
                    ),
                    DropdownMenuItem(
                      value: 'Dessert',
                      child: Text('Dessert'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _kategori = value);
                    }
                  },
                ),
              ),
              _buildField(
                label: 'Harga Beli',
                controller: _hargaBeliController,
                icon: Icons.shopping_cart_outlined,
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              _buildField(
                label: 'Harga Jual',
                controller: _hargaJualController,
                icon: Icons.sell_outlined,
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              _buildField(
                label: 'Stok',
                controller: _stokController,
                icon: Icons.warehouse_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok wajib diisi';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 0) {
                    return 'Stok harus berupa bilangan bulat positif';
                  }
                  return null;
                },
              ),
              _buildField(
                label: 'URL / Path Gambar (Opsional)',
                controller: _gambarController,
                icon: Icons.image_outlined,
                validator: (value) => null,
              ),
              _buildField(
                label: 'Diskon (%)',
                controller: _diskonController,
                icon: Icons.discount_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Isi diskon';
                  final number = int.tryParse(value);
                  if (number == null || number < 0 || number > 100) {
                    return 'Diskon harus 0–100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _simpanProduk,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Produk',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // Tombol Hapus (Hanya muncul jika sedang dalam mode Edit Produk)
              if (_isEdit) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _konfirmasiHapus,
                  icon: const Icon(Icons.delete),
                  label: const Text(
                    'Hapus Produk Ini',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}