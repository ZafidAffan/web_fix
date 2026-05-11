import 'dart:convert';
import 'dart:html' as html; // Flutter Web localStorage
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.202:3000/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailC.text,
          "password": passC.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String token = data['token'];
        final Map<String, dynamic> user = data['user'];

        final String role = user['role'];
        final String divisi = user['divisi'] ?? '';
        final String nama = user['nama'] ?? user['email'];

        html.window.localStorage['token'] = token;
        html.window.localStorage['role'] = role;
        html.window.localStorage['divisi'] = divisi;
        html.window.localStorage['nama'] = nama;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login berhasil, selamat datang $nama")),
        );

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (role == 'kepala') {
          Navigator.pushReplacementNamed(context, '/kepala');
        } else if (role == 'umum') {
          Navigator.pushReplacementNamed(context, '/umum');
        } else if (role == 'divisi') {
          Navigator.pushReplacementNamed(context, '/divisi');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔥 HEADER IMAGE
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/gedung.jpeg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.blue.withOpacity(0.5),
                ),
                const Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    "Monitoring Surat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Silahkan login, jika belum punya akun silahkan hubungi pihak divisi umum",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 📩 EMAIL
                  TextField(
                    controller: emailC,
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔒 PASSWORD
                  TextField(
                    controller: passC,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔘 BUTTON LOGIN
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}