import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tugaspert4_mp/model/Product.dart';
import 'package:tugaspert4_mp/service/api_service.dart';

class DetailProductPage extends StatefulWidget {
  final Product product;
  const DetailProductPage({super.key, required this.product});

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = widget.product.stock <= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text('Detail Produk'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.product.imagePath != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(16), child: kIsWeb ? Image.network(widget.product.imagePath!) : Image.file(File(widget.product.imagePath!))),
                ),
                const SizedBox(height: 20),
              ],
              Text(widget.product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.product.price, style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                  // INDIKATOR STOK DI DETAIL BARANG
                  Text(isOutOfStock ? "Stok Habis" : "Stok: ${widget.product.stock} pcs", style: TextStyle(color: isOutOfStock ? Colors.red : Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 36, thickness: 1),
              Text(widget.product.description, style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 32),
              
              // ◄ TOMBOL AKSI TRANSAKSI DI HALAMAN DETAIL PRODUK
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: isOutOfStock ? null : () {
                        String msg = _apiService.addToCart(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        setState(() {});
                      },
                      child: const Text('Keranjang 🛒'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: isOutOfStock ? null : () {
                        _apiService.buyDirectly(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pembelian Berhasil! Stok dikurangi 📦"), backgroundColor: Colors.green));
                        setState(() {});
                      },
                      child: const Text('Beli Sekarang'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}