import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, String> userData;
  final bool isDataSaved;

  const ProfilePage({super.key, required this.userData, required this.isDataSaved});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showDetail = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isDataSaved) {
      return const Scaffold(body: Center(child: Text("Isi data di Beranda dulu ya! ✨")));
    }

    final d = widget.userData;

    // Logika untuk memecah teks interests dari Beranda menjadi list kotak (Chips)
    List<String> interestsList = d['interests'] != null && d['interests']!.isNotEmpty
        ? d['interests']!.split(',').map((e) => e.trim()).toList()
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Cantik
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    // --- BAGIAN INI DITAMBAHKAN BACKGROUND GAMBAR ---
                    image: DecorationImage(
                      image: NetworkImage('https://i.ibb.co.com/276nK8xF/Whats-App-Image-2026-04-18-at-20-35-14.jpg'),
                      fit: BoxFit.cover,
                    ),
                    // ------------------------------------------------
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                ),
                Positioned(
                  top: 140,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: const NetworkImage('https://i.ibb.co.com/ZpxFRJL8/Whats-App-Image-2026-04-18-at-19-37-45.jpg'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            // Nama & Info Singkat
            Text(d['nama'] ?? "", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                Text(d['lokasi'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
            
            const SizedBox(height: 24),

            // --- BAGIAN SKILLS & INTERESTS (CENTERED) ---
if (interestsList.isNotEmpty) ...[
  const SizedBox(height: 10),
  const Text(
    "Skills & Interests", 
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E))
  ),
  const SizedBox(height: 8),
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center, // Membuat chips ke tengah
      children: interestsList.map((interest) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
        ),
        child: Text(
          interest,
          style: const TextStyle(
            color: Colors.blueAccent, 
            fontWeight: FontWeight.w600, 
            fontSize: 12
          ),
        ),
      )).toList(),
    ),
  ),
  const SizedBox(height: 20),
],
            // ------------------------------------------

            // Card Statistik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard("Project", "9999", Colors.orange),
                  const SizedBox(width: 15),
                  _buildStatCard("Followers", "9999", Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Detail Modern
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                onTap: () => setState(() => showDetail = !showDetail),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Informasi Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Icon(showDetail ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.blueAccent),
                    ],
                  ),
                ),
              ),
            ),

            if (showDetail) ...[
              const SizedBox(height: 15),
              _buildInfoItem(Icons.work_rounded, "Jabatan", d['jabatan']!),
              _buildInfoItem(Icons.psychology, "Profesi", d['profesi']!),
              _buildInfoItem(Icons.email_rounded, "Email", d['email']!),
              _buildInfoItem(Icons.phone_iphone_rounded, "Kontak", d['hp']!),
              
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tentang Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      const SizedBox(height: 10),
                      Text(d['tentang']!, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: Colors.blueAccent.withOpacity(0.1), child: Icon(icon, size: 18, color: Colors.blueAccent)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}