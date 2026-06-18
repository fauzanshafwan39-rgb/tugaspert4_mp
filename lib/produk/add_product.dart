import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugaspert4_mp/model/Product.dart';
import 'package:tugaspert4_mp/service/api_service.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController(); // ◄ Controller Stok Baru [cite: Mobile Programming - Pertemuan 13.pptx]
  final ApiService _apiService = ApiService();

  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price;
      _descController.text = widget.product!.description;
      _stockController.text = widget.product!.stock.toString(); // Ambil stok lama [cite: Mobile Programming - Pertemuan 13.pptx]
      _selectedImagePath = widget.product!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      int stokInt = int.tryParse(_stockController.text) ?? 0;

      if (widget.product == null) {
        _apiService.addProduct(Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
          description: _descController.text.trim(),
          stock: stokInt, // ◄ Masukkan stok baru [cite: Mobile Programming - Pertemuan 13.pptx]
          imagePath: _selectedImagePath,
        ));
      } else {
        _apiService.updateProduct(Product(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
          description: _descController.text.trim(),
          stock: stokInt, // ◄ Update stok lama [cite: Mobile Programming - Pertemuan 13.pptx]
          imagePath: _selectedImagePath,
        ));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2)),
                  child: _selectedImagePath != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(18), child: kIsWeb ? Image.network(_selectedImagePath!) : Image.file(File(_selectedImagePath!)))
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.blueAccent), SizedBox(height: 8), Text("Pilih Gambar Produk")]),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(controller: _nameController, label: 'Nama Produk', icon: Icons.shopping_bag_outlined, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 20),
              
              // ◄ KOLOM INPUT STOK BARANG [cite: Mobile Programming - Pertemuan 13.pptx]
              _buildTextField(
                controller: _stockController, 
                label: 'Jumlah Stok Awal', 
                icon: Icons.inventory_2_outlined, 
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty || int.tryParse(v) == null ? 'Masukkan jumlah stok valid' : null
              ),
              const SizedBox(height: 20),
              
              _buildTextField(controller: _priceController, label: 'Harga Produk', hint: 'Contoh: Rp 50.000', icon: Icons.payments_outlined, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 20),
              _buildTextField(controller: _descController, label: 'Deskripsi Produk', icon: Icons.description_outlined, maxLines: 4, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Produk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, String? hint, int maxLines = 1, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}