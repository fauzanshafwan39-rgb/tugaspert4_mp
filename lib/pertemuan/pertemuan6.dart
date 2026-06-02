import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  _CheckboxPageState createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _kelasController = TextEditingController();
  
  bool _isCheckedSyarat = false;

  // Palette Warna Modern (Indigo & Lavender)
  final Color primaryColor = const Color(0xFF6366F1); 
  final Color accentColor = const Color(0xFF818CF8);

  // Data Hobi (Checkbox)
  final Map<String, bool> _hobbies = {
    'Membaca': false,
    'Olahraga': false,
    'Musik': false,
    'Game': false,
    'Traveling': false,
    'Coding': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Student Registration", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Data Mahasiswa", Icons.school_outlined),
              _buildCard([
                _buildTextField(_namaController, "Nama Lengkap", Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(_nimController, "NIM", Icons.badge_outlined, isNumber: true),
                const SizedBox(height: 16),
                _buildTextField(_kelasController, "Kelas", Icons.class_outlined),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader("Minat & Hobi", Icons.favorite_border),
              _buildHobbyGrid(),

              const SizedBox(height: 24),
              // Checkbox Syarat & Ketentuan
              CheckboxListTile(
                title: const Text("Saya menyetujui syarat dan ketentuan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                value: _isCheckedSyarat,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _isCheckedSyarat = v!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),
              // Tombol Daftar
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [primaryColor, accentColor]),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
    );
  }

  Widget _buildHobbyGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _hobbies.keys.map((hobby) {
          bool isSelected = _hobbies[hobby]!;
          return FilterChip(
            label: Text(hobby),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                _hobbies[hobby] = selected;
              });
            },
            selectedColor: primaryColor.withOpacity(0.2),
            checkmarkColor: primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        }).toList(),
      ),
    );
  }

  // --- LOGIC SIMPAN & MODAL (ESTETIK) ---

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validasi: Minimal 1 hobi dipilih
      if (!_hobbies.values.any((element) => element)) {
        Fluttertoast.showToast(msg: "Pilih minimal satu hobi!", gravity: ToastGravity.CENTER);
        return;
      }
      
      // Validasi: Syarat & Ketentuan
      if (!_isCheckedSyarat) {
        Fluttertoast.showToast(msg: "Setujui syarat & ketentuan!", gravity: ToastGravity.CENTER);
        return;
      }

      List<String> selectedHobbies = _hobbies.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFF4CAF50),
                child: Icon(Icons.check, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 20),
              const Text("Pendaftaran Berhasil", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 30),
              
              _buildSummaryRow("Nama", _namaController.text),
              _buildSummaryRow("NIM", _nimController.text),
              _buildSummaryRow("Hobi", selectedHobbies.join(", ")),
              
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Selesai", style: TextStyle(fontSize: 18, color: primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(value, 
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}