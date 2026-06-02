import 'package:flutter/material.dart';
import 'detail_materi_page.dart'; 
import 'package:tugaspert4_mp/pertemuan/pertemuan6.dart';
import 'package:tugaspert4_mp/pertemuan/pertemuan7.dart'; 
import 'package:tugaspert4_mp/pertemuan/pertemuan8.dart';
import 'package:tugaspert4_mp/pertemuan/pertemuan9.dart'; // Import Pertemuan 9 baru

class BerandaPage extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final VoidCallback onDelete;
  final bool showForm;
  final Function(bool) onToggleForm;
  final Map<String, String> userData;

  const BerandaPage({
    super.key,
    required this.onSave,
    required this.onDelete,
    required this.showForm,
    required this.onToggleForm,
    required this.userData,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String? _selectedCategory;
  final List<String> _categories = ['Semua', 'Teori', 'Praktikum', 'Tugas'];
  String _searchQuery = "";

  // DATA MATERI UTAMA (Teks asli dipertahankan, ditambah Pertemuan 9)
  final List<Map<String, dynamic>> materi = [
    {
      "judul": "Pertemuan 1", 
      "sub": "Pengenalan Android", 
      "desc": "Mempelajari dasar-dasar Android Studio dan arsitektur mobile apps.",
      "color": Colors.pinkAccent
    },
    {
      "judul": "Pertemuan 2", 
      "sub": "Widget & Button", 
      "desc": "Eksperimen dengan berbagai widget UI seperti Row, Column, dan Button.",
      "color": Colors.orangeAccent
    },
    {
      "judul": "Pertemuan 3", 
      "sub": "Activity & Intent", 
      "desc": "Belajar cara berpindah halaman dan membawa data antar screen.",
      "color": Colors.purpleAccent
    },
    {
      "judul": "Pertemuan 4", 
      "sub": "Toast & AlertDialog", 
      "desc": "Implementasi notifikasi popup dan dialog konfirmasi user.",
      "color": Colors.greenAccent
    },
    {
      "judul": "Pertemuan 5", 
      "sub": "ListView", 
      "desc": "Menampilkan data dinamis dalam bentuk daftar yang bisa di-scroll.",
      "color": Colors.blueAccent
    },
    {
      "judul": "Pertemuan 6", 
      "sub": "Checkbox", 
      "desc": "Mengelola input pilihan ganda untuk form aplikasi.",
      "color": Colors.tealAccent
    },
    {
      "judul": "Pertemuan 7", 
      "sub": "Radio Button", 
      "desc": "Implementasi pilihan tunggal menggunakan widget Radio.",
      "color": Colors.amberAccent
    },
    {
      "judul": "Pertemuan 8", 
      "sub": "Autocomplete & Spinner", 
      "desc": "Implementasi input teks otomatis dan dropdown menu.",
      "color": Colors.redAccent
    },
    {
      "judul": "Pertemuan 9", 
      "sub": "Date & Time Picker", 
      "desc": "Implementasi pemilihan komponen penanggalan dan waktu sistem.",
      "color": Colors.indigoAccent
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Logika Filter Pencarian
    List<Map<String, dynamic>> filteredMateri = materi.where((item) {
      return item['judul']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          // HEADER
          SliverAppBar(
            expandedHeight: 110.0,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1976D2),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 55, left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, ${widget.userData['nama'] ?? 'Pelajar'} 👋",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text("Ayo lanjutkan belajarmu!", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SEARCH BOX & SPINNER
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -25),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    children: [
                      Autocomplete<String>(
                        optionsBuilder: (textVal) => textVal.text == '' 
                          ? const Iterable<String>.empty() 
                          : materi.map((e) => e['judul'] as String).where((j) => j.toLowerCase().contains(textVal.text.toLowerCase())),
                        onSelected: (val) => setState(() => _searchQuery = val),
                        fieldViewBuilder: (ctx, ctrl, node, onSub) {
                          return TextField(
                            controller: ctrl,
                            focusNode: node,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Cari modul kuliah...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.blueAccent),
                              filled: true,
                              fillColor: const Color(0xFFF0F5FF),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 38,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F5FF),
                            prefixIcon: const Icon(Icons.category_rounded, size: 18, color: Colors.blueAccent),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                          hint: const Text("Tipe Materi", style: TextStyle(fontSize: 12)),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // GRID MODUL (BUBBLE STYLE)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85, 
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredMateri[index];
                  return GestureDetector(
                    onTap: () => _handleNavigation(context, item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: (item['color'] as Color).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.auto_stories_rounded, size: 28, color: item['color']),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['judul']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              item['sub']!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: filteredMateri.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, Map<String, dynamic> item) {
    if (item['judul'] == "Pertemuan 6") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckboxPage()));
    } else if (item['judul'] == "Pertemuan 7") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RadiobuttonPage()));
    } else if (item['judul'] == "Pertemuan 8") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Pertemuan8Page()));
    } else if (item['judul'] == "Pertemuan 9") { // Navigasi baru untuk Pertemuan 9
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Pertemuan9Page()));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => DetailMateriPage(
          judul: item['judul']!, 
          sub: item['sub']!, 
          deskripsi: item['desc']!,
        ),
      ));
    }
  }
}