import 'package:flutter/material.dart';

class Pertemuan8Page extends StatefulWidget {
  const Pertemuan8Page({super.key});

  @override
  State<Pertemuan8Page> createState() => _Pertemuan8PageState();
}

class _Pertemuan8PageState extends State<Pertemuan8Page> {
  // Data dummy yang diperbanyak
  final List<String> _kategoriGunung = [
    'Sumbing', 'Pangrango', 'Gede', 'Prau', 'Rinjani', 
    'Semeru', 'Merbabu', 'Lawu', 'Slamet', 'Sindoro', 'Kerinci'
  ];
  
  String? _selectedLevel;
  final List<String> _levels = ['Pemula', 'Menengah', 'Ahli', 'Profesional'];

  double _jumlahAnggota = 1;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Warna background soft
      appBar: AppBar(
        title: const Text("Form Registrasi Pendakian", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Agar bisa di-scroll jika keyboard muncul
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Card Pembungkus Form
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Data Perjalanan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    const Divider(),
                    const SizedBox(height: 15),

                    // Input Nama (Tambahan agar lebih lengkap)
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Nama Koordinator',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Autocomplete Field (Cari Destinasi)
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return _kategoriGunung.where((String option) {
                          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Cari Destinasi Gunung',
                            prefixIcon: Icon(Icons.landscape_outlined),
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Spinner / Dropdown (Level Pendakian)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Level Kesulitan',
                        prefixIcon: Icon(Icons.trending_up),
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedLevel,
                      items: _levels.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLevel = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date Picker (Tambahan)
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Keberangkatan',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDate == null 
                            ? "Pilih Tanggal" 
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Slider (Jumlah Anggota)
                    Text("Jumlah Anggota: ${_jumlahAnggota.toInt()} Orang"),
                    Slider(
                      value: _jumlahAnggota,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: _jumlahAnggota.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _jumlahAnggota = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data Berhasil Disimpan')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Simpan Pendaftaran", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}