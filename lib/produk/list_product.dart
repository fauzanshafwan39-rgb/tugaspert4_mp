import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// MEMASTIKAN IMPOR RESMI PACKAGE AGAR TIDAK MERAH BERGELOMBANG
import 'package:tugaspert4_mp/model/Product.dart';
import 'package:tugaspert4_mp/service/api_service.dart';
import 'package:tugaspert4_mp/produk/add_product.dart';
import 'package:tugaspert4_mp/produk/detail_product.dart';

class ListProductPage extends StatefulWidget {
  const ListProductPage({super.key});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _products = _apiService.getProducts();
    });
  }

  // ◄ LEMBAR POPUP KERANJANG BELANJA (BOTTOM SHEET)
  void _openCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int totalBayar = ApiService.globalCart.fold(0, (sum, item) => sum + item.totalItemPrice);
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, 
                left: 20, 
                right: 20, 
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keranjang Belanja Kamu 🛒', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  ApiService.globalCart.isEmpty
                      ? const SizedBox(height: 150, child: Center(child: Text("Keranjang kosong.")))
                      : SizedBox(
                          height: 250,
                          child: ListView.builder(
                            itemCount: ApiService.globalCart.length,
                            itemBuilder: (context, i) {
                              final item = ApiService.globalCart[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${item.product.price} x ${item.quantity}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                      onPressed: () {
                                        _apiService.changeCartQuantity(item.product.id, item.quantity - 1);
                                        setModalState(() {});
                                        _refreshData();
                                      },
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                      onPressed: () {
                                        _apiService.changeCartQuantity(item.product.id, item.quantity + 1);
                                        setModalState(() {});
                                        _refreshData();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                  if (ApiService.globalCart.isNotEmpty) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          'Rp ${totalBayar.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', 
                          style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, 
                          foregroundColor: Colors.white, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          _apiService.checkoutCart();
                          Navigator.pop(context);
                          _refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Checkout Berhasil! Stok barang otomatis dikurangi ✨"), 
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Checkout & Kurangi Stok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItemsInCart = ApiService.globalCart.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Toko Produk Latihan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_rounded, size: 26), onPressed: _openCartBottomSheet),
              if (totalItemsInCart > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text('$totalItemsInCart', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                )
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _products.isEmpty
          ? const Center(child: Text("Belum ada produk.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                bool isOutOfStock = product.stock <= 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
                          child: product.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14), 
                                  child: kIsWeb 
                                      ? Image.network(product.imagePath!, fit: BoxFit.cover) 
                                      : Image.file(File(product.imagePath!), fit: BoxFit.cover),
                                )
                              : const Icon(Icons.shopping_bag_rounded, color: Colors.blueAccent, size: 30),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(product.price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOutOfStock ? Colors.red.withOpacity(0.1) : Colors.blueAccent.withOpacity(0.1), 
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isOutOfStock ? "Stok Habis ❌" : "Stok: ${product.stock} unit", 
                                style: TextStyle(color: isOutOfStock ? Colors.red : Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        // FIXED: Menyamakan parameter (val) dengan kondisi pengecekan di bawahnya
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'detail') {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailProductPage(product: product))).then((_) => _refreshData());
                            } else if (val == 'edit') {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductPage(product: product))).then((_) => _refreshData());
                            } else if (val == 'delete') {
                              _apiService.deleteProduct(product.id);
                              _refreshData();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'detail', child: Text('Detail')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                // FIXED: Mengubah ke buyDirectly agar memotong stok riil di api_service
                                onPressed: isOutOfStock ? null : () {
                                  bool success = _apiService.buyDirectly(product); 
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Beli instan sukses! Stok dikurangi. 📦"), behavior: SnackBarBehavior.floating),
                                    );
                                  }
                                  _refreshData();
                                },
                                icon: const Icon(Icons.flash_on_rounded, size: 16),
                                label: const Text('Beli Instan', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blueAccent,
                                  side: const BorderSide(color: Colors.blueAccent),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                // FIXED: Mengubah ke addToCart agar masuk ke list keranjang belanja global
                                onPressed: isOutOfStock ? null : () {
                                  String msg = _apiService.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
                                  );
                                  _refreshData();
                                },
                                icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                                label: const Text('Keranjang', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductPage())).then((_) => _refreshData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}