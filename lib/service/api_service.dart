import 'package:tugaspert4_mp/model/Product.dart';

class ApiService {
  // Simpan data produk dummy lengkap dengan nilai stok awal [cite: Mobile Programming - Pertemuan 13.pptx]
  static List<Product> dummyProducts = [
    Product(
      id: "1", 
      name: "Modul Mobile Programming", 
      price: "Rp 45.000", 
      description: "Buku panduan praktikum Flutter lengkap untuk semester 4.",
      stock: 12, // ◄ Stok Modul [cite: Mobile Programming - Pertemuan 13.pptx]
      imagePath: null,
    ),
    Product(
      id: "2", 
      name: "Kaos Universitas Pamulang", 
      price: "Rp 85.000", 
      description: "Kaos eksklusif bahan cotton combed 30s premium.",
      stock: 5, // ◄ Stok Kaos [cite: Mobile Programming - Pertemuan 13.pptx]
      imagePath: null,
    ),
  ];

  // ◄ DEKLARASI DATA KERANJANG BELANJA SECARA GLOBAL
  static List<CartItem> globalCart = [];

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
    globalCart.removeWhere((item) => item.product.id == id); // Hapus dari keranjang juga jika produk dihapus
  }

  // ==================== LOGIKA KERANJANG BELANJA ====================

  String addToCart(Product product) {
    if (product.stock <= 0) {
      return "Stok produk habis!";
    }

    int index = globalCart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (globalCart[index].quantity >= product.stock) {
        return "Gagal! Jumlah di keranjang sudah melebihi stok produk.";
      }
      globalCart[index].quantity++;
    } else {
      globalCart.add(CartItem(product: product));
    }
    return "Berhasil ditambahkan ke keranjang! 🛒";
  }

  void changeCartQuantity(String productId, int newQty) {
    int index = globalCart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (newQty <= 0) {
        globalCart.removeAt(index);
      } else if (newQty <= globalCart[index].product.stock) {
        globalCart[index].quantity = newQty;
      }
    }
  }

  // ◄ PROSES CHECKOUT: OTOMATIS MENGURANGI STOK RIIL PRODUK [cite: Mobile Programming - Pertemuan 13.pptx]
  bool checkoutCart() {
    if (globalCart.isEmpty) return false;

    for (var item in globalCart) {
      int idx = dummyProducts.indexWhere((p) => p.id == item.product.id);
      if (idx != -1) {
        dummyProducts[idx].stock -= item.quantity; // Stok berkurang [cite: Mobile Programming - Pertemuan 13.pptx]
        if (dummyProducts[idx].stock < 0) dummyProducts[idx].stock = 0;
      }
    }
    globalCart.clear(); // Bersihkan keranjang
    return true;
  }

  // ◄ BELI SEKARANG (LANGSUNG BELI 1 BIJI)
  bool buyDirectly(Product product) {
    int idx = dummyProducts.indexWhere((p) => p.id == product.id);
    if (idx != -1 && dummyProducts[idx].stock > 0) {
      dummyProducts[idx].stock--; // Langsung potong stok 1 biji [cite: Mobile Programming - Pertemuan 13.pptx]
      return true;
    }
    return false;
  }
}