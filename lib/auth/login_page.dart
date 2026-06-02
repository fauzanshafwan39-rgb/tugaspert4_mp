import 'package:flutter/material.dart';
import 'package:tugaspert4_mp/main.dart'; // Wajib untuk membaca MyAppState

class LoginPage extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const LoginPage({super.key, required this.onClickedSignUp});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void signIn() {
    if (_formKey.currentState!.validate()) {
      String emailUser = _emailController.text.trim();
      String namaUser = emailUser.split('@')[0]; // Ambil nama depan dari email

      // MEMPERBAIKI AKSES STATE: Langsung menembak MyAppState di main.dart
      final mainState = context.findAncestorStateOfType<MyAppState>();
      if (mainState != null) {
        mainState.handleSave({
          'nama': namaUser,
          'email': emailUser,
        });

        // Tampilkan feedback login sukses yang rapi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selamat Datang Kembali, $namaUser! ✨"),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Background abu-abu pastel mewah senada dengan register
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. IKON LOGO HEADER YANG MEWAH
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    size: 60,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. TEXT JUDUL UTAMA DENGAN STYLE MODERN
                const Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'Silakan masuk untuk mengakses modul kuliah Anda',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // 3. INPUT FIELD EMAIL (STYLE FLATING CARD, SAMA SEPERTI BERANDA)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Masukkan alamat email Anda',
                      prefixIcon: const Icon(Icons.email_rounded, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none, // Hilangkan garis border bawaan yang kaku
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Email wajib diisi' : null,
                  ),
                ),
                const SizedBox(height: 20),

                // 4. INPUT FIELD PASSWORD BUBBLE DESIGN
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Masukkan password Anda',
                      prefixIcon: const Icon(Icons.key_rounded, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Password wajib diisi' : null,
                  ),
                ),
                const SizedBox(height: 32),

                // 5. TOMBOL SIGN IN UTAMA DENGAN EMBOSS SHADOW BLUE
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.blueAccent.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. LAYOUT LINK PINDAH KE REGISTER PAGE
                TextButton(
                  onPressed: widget.onClickedSignUp,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    'Belum punya akun? Daftar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}