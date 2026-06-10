import 'package:flutter/material.dart';
// MEMPERBAIKI IMPOR JALUR PACKAGE BIAR TIDAK MERAH BERGELOMBANG
import 'package:tugaspert4_mp/model/Product.dart';

class DetailProductPage extends StatelessWidget {
  final Product product;
  const DetailProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Detail Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // NAMA PRODUK
              Text(
                product.name, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              
              // HARGA PRODUK
              Text(
                product.price, 
                style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 36, thickness: 1),
              
              // LABEL DESKRIPSI
              const Row(
                children: [
                  Icon(Icons.text_snippet_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    'Deskripsi Produk :', 
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // ISI DESKRIPSI PRODUK
              Text(
                product.description, 
                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}