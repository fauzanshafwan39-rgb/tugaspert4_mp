class Product {
  final String id;
  final String name;
  final String price;
  final String description;
  final String? imagePath;
  int stock; // ◄ Properti Stok Produk [cite: Mobile Programming - Pertemuan 13.pptx]

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.stock, // ◄ Wajib diisi [cite: Mobile Programming - Pertemuan 13.pptx]
    this.imagePath,
  });
}

// ◄ MODEL KHUSUS UNTUK MENAMPUNG ITEM DI DALAM KERANJANG
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Helper untuk mengubah string harga "Rp 45.000" menjadi angka int asli agar bisa dikali
  int get priceAsInt {
    String clean = product.price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  int get totalItemPrice => priceAsInt * quantity;
}