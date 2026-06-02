import 'package:flutter/material.dart';

class Pertemuan9Page extends StatefulWidget {
  const Pertemuan9Page({super.key});

  @override
  State<Pertemuan9Page> createState() => _Pertemuan9PageState();
}

class _Pertemuan9PageState extends State<Pertemuan9Page> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Fungsi memanggil Date Picker
  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      // Tema imut untuk picker
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigoAccent, 
              onPrimary: Colors.white, 
              onSurface: Colors.indigo, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Fungsi memanggil Time Picker
  Future<void> _pilihWaktu(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Schedule Form", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Atur Jadwal Pertemuan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pilih tanggal dan waktu pelaksanaan tugas.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // CARD UNTUK TANGGAL
            _buildPickerCard(
              title: "Tanggal Pelaksanaan",
              value: _selectedDate == null 
                  ? "Pilih Tanggal" 
                  : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
              icon: Icons.calendar_month_rounded,
              color: Colors.pinkAccent,
              onTap: () => _pilihTanggal(context),
            ),

            const SizedBox(height: 20),

            // CARD UNTUK WAKTU
            _buildPickerCard(
              title: "Jam Pelaksanaan",
              value: _selectedTime == null 
                  ? "Pilih Waktu" 
                  : _selectedTime!.format(context),
              icon: Icons.alarm_rounded,
              color: Colors.orangeAccent,
              onTap: () => _pilihWaktu(context),
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN IMUT
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jadwal Berhasil Disimpan ✨")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  shadowColor: Colors.indigoAccent.withOpacity(0.4),
                ),
                child: const Text("Simpan Jadwal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk membuat kartu Picker yang imut
  Widget _buildPickerCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}