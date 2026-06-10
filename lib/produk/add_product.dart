import 'package:flutter/material.dart';
// MENAMBAHKAN IMPORT BIAR GA EROR MERAH JALUR FILE-NYA
import 'package:tugaspert4_mp/model/Product.dart';
import 'package:tugaspert4_mp/service/api_service.dart';

class AddProductPage extends StatefulWidget {
  final Product? product; // Kalau kosong berarti tambah baru, kalau ada isinya berarti edit
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Kalau modenya edit, masukin data lama ke input field
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price;
      _descController.text = widget.product!.description;
    }
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      if (widget.product == null) {
        // Logika Tambah Baru
        _apiService.addProduct(Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
          description: _descController.text.trim(),
        ));
      } else {
        // Logika Simpan Hasil Edit
        _apiService.updateProduct(Product(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
          description: _descController.text.trim(),
        ));
      }
      Navigator.pop(context); // Tutup halaman dan balik ke list
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // INPUT NAMA
              _buildTextField(
                controller: _nameController,
                label: 'Nama Produk',
                icon: Icons.shopping_bag_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // INPUT HARGA
              _buildTextField(
                controller: _priceController,
                label: 'Harga Produk',
                hint: 'Contoh: Rp 50.000',
                icon: Icons.payments_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Harga produk wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // INPUT DESKRIPSI
              _buildTextField(
                controller: _descController,
                label: 'Deskripsi Produk',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 36),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
            blurRadius: 8, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          // MENGAKTIFKAN GARIS BORDER HALUS AGAR ANIMASI LABEL BERJALAN NORMAL
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }
}