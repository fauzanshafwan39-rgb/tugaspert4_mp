// MEMPERBAIKI JALUR IMPOR PAKAI PACKAGE RESMI BIAR TIDAK EROR MERAH
import 'package:tugaspert4_mp/model/Product.dart';

class ApiService {
  // Disimpan di dalam list static supaya data tidak hilang saat pindah-pindah halaman
  static List<Product> dummyProducts = [
    Product(
      id: "1", 
      name: "Modul Mobile Programming", 
      price: "Rp 45.000", 
      description: "Buku panduan praktikum Flutter lengkap untuk semester 4.",
    ),
    Product(
      id: "2", 
      name: "Kaos Universitas Pamulang", 
      price: "Rp 85.000", 
      description: "Kaos eksklusif bahan cotton combed 30s premium.",
    ),
  ];

  List<Product> getProducts() {
    return dummyProducts;
  }

  void addProduct(Product product) {
    dummyProducts.add(product);
  }

  void updateProduct(Product updatedProduct) {
    int index = dummyProducts.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      dummyProducts[index] = updatedProduct;
    }
  }

  void deleteProduct(String id) {
    dummyProducts.removeWhere((p) => p.id == id);
  }
}