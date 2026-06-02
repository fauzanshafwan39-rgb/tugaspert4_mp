import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RadiobuttonPage extends StatefulWidget {
  const RadiobuttonPage({super.key});

  @override
  _RadiobuttonPageState createState() => _RadiobuttonPageState();
}

class _RadiobuttonPageState extends State<RadiobuttonPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();

  String? _selectedGender;
  String? _selectedJob;
  String? _selectedWorkType;

  // Palette Warna Estetik
  final Color primaryColor = const Color(0xFF6366F1); // Indigo Modern
  final Color accentColor = const Color(0xFF818CF8);
  final Color backgroundColor = const Color(0xFFF9FAFB);

  final List<Map<String, dynamic>> _jobOptions = [
    {'value': 'Admin', 'icon': Icons.support_agent, 'color': Color(0xFF3B82F6)},
    {'value': 'Guru', 'icon': Icons.school, 'color': Color(0xFF10B981)},
    {'value': 'Programmer', 'icon': Icons.code, 'color': Color(0xFF6366F1)},
    {'value': 'Pengusaha', 'icon': Icons.business, 'color': Color(0xFFF59E0B)},
    {'value': 'Desainer', 'icon': Icons.design_services, 'color': Color(0xFFEC4899)},
  ];

  final List<Map<String, dynamic>> _workTypeOptions = [
    {'value': 'Full Time', 'desc': 'Prioritas Utama', 'icon': Icons.timer},
    {'value': 'Part Time', 'desc': 'Fleksibel', 'icon': Icons.shutter_speed},
    {'value': 'Freelance', 'desc': 'Remote-ready', 'icon': Icons.laptop_mac},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Estetik dengan Gradasi
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Form dengan Radio Button", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Personal Info", Icons.badge_outlined),
                    _buildInputCard([
                      _buildTextField(_namaController, "Nama Lengkap", Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildTextField(_umurController, "Umur", Icons.calendar_today_outlined, isNumber: true),
                    ]),

                    const SizedBox(height: 32),
                    _buildSectionHeader("Identity", Icons.face_outlined),
                    _buildGenderSelector(),

                    const SizedBox(height: 32),
                    _buildSectionHeader("Specialization", Icons.work_outline),
                    _buildJobGrid(),

                    const SizedBox(height: 32),
                    _buildSectionHeader("Work Commitment", Icons.bolt_outlined),
                    _buildWorkTypeSelector(),

                    const SizedBox(height: 48),
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget Helper: Judul Section
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade800)),
        ],
      ),
    );
  }

  // Widget Helper: Input Card
  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Widget Helper: Custom TextField
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
      validator: (v) => v!.isEmpty ? "$label tidak boleh kosong" : null,
    );
  }

  // Widget Helper: Custom Gender Toggle
  Widget _buildGenderSelector() {
    return Row(
      children: ["Pria", "Wanita"].map((gender) {
        bool isSelected = _selectedGender == gender;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = gender),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: gender == "Pria" ? 12 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200),
              ),
              child: Center(
                child: Text(gender, 
                  style: TextStyle(color: isSelected ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget Helper: Job Grid (Chips Modern)
  Widget _buildJobGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _jobOptions.map((job) {
        bool isSelected = _selectedJob == job['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedJob = job['value']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? job['color'] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected ? [BoxShadow(color: job['color'].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
              border: Border.all(color: isSelected ? job['color'] : Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(job['icon'], size: 18, color: isSelected ? Colors.white : job['color']),
                const SizedBox(width: 8),
                Text(job['value'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget Helper: Work Type Tile
  Widget _buildWorkTypeSelector() {
    return Column(
      children: _workTypeOptions.map((type) {
        bool isSelected = _selectedWorkType == type['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedWorkType = type['value']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 2),
            ),
            child: Row(
              children: [
                Icon(type['icon'], color: isSelected ? primaryColor : Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type['value'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(type['desc'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Radio<String>(
                  value: type['value'],
                  groupValue: _selectedWorkType,
                  activeColor: primaryColor,
                  onChanged: (v) => setState(() => _selectedWorkType = v),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget Helper: Button
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [primaryColor, accentColor]),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text("Complete Registration", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null || _selectedJob == null || _selectedWorkType == null) {
        Fluttertoast.showToast(msg: "Please complete all selections", gravity: ToastGravity.CENTER);
        return;
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text("Data Berhasil Disimpan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildSummaryRow("Nama", _namaController.text),
              _buildSummaryRow("Profesi", _selectedJob!),
              _buildSummaryRow("Tipe", _selectedWorkType!),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Selesai", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}