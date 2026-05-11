import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final jabatanC = TextEditingController();

  String? selectedRole;
  int? selectedDivisi;

  bool isLoading = false;

  List divisiList = [];

  final List<String> roles = [
    "admin",
    "kepala",
    "divisi",
    "umum"
  ];

  // ================= GET DIVISI =================
  Future<void> getDivisi() async {
    try {

      final response = await http.get(
        Uri.parse("http://192.168.1.202:3000/api/auth/divisi")
      );

      if(response.statusCode == 200){
        setState(() {
          divisiList = jsonDecode(response.body);
        });
      }

    } catch(e){
      print(e);
    }
  }

  // ================= REGISTER =================
  Future<void> register() async {

    if (namaC.text.isEmpty ||
        emailC.text.isEmpty ||
        passC.text.isEmpty ||
        jabatanC.text.isEmpty ||
        selectedRole == null ||
        selectedDivisi == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );

      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await http.post(
        Uri.parse("http://127.0.0.1:3000/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": namaC.text,
          "email": emailC.text,
          "password": passC.text,
          "jabatan": jabatanC.text,
          "role": selectedRole,
          "id_divisi": selectedDivisi
        }),
      );

      final data = jsonDecode(response.body);

      if(response.statusCode == 201){

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User berhasil dibuat")),
        );

        Navigator.pop(context);

      }else{

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Registrasi gagal")),
        );

      }

    }catch(e){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error : $e")),
      );

    }

    setState(() => isLoading = false);

  }

  InputDecoration inputStyle(String label, IconData icon) {

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

  }

  @override
  void initState() {
    super.initState();
    getDivisi();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Register User"),
        backgroundColor: Colors.blue,
      ),

      body: Center(

        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.all(25),

            child: Column(

              children: [

                const Text(
                  "Tambah User",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: namaC,
                  decoration: inputStyle("Nama", Icons.person),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: emailC,
                  decoration: inputStyle("Email", Icons.email),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passC,
                  obscureText: true,
                  decoration: inputStyle("Password", Icons.lock),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: jabatanC,
                  decoration: inputStyle("Jabatan", Icons.work),
                ),

                const SizedBox(height: 20),

                // ROLE
                DropdownButtonFormField<String>(

                  value: selectedRole,

                  decoration: inputStyle("Role", Icons.admin_panel_settings),

                  items: roles.map((role){

                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );

                  }).toList(),

                  onChanged: (value){

                    setState(() {
                      selectedRole = value;
                    });

                  },

                ),

                const SizedBox(height: 20),

                // DIVISI
                DropdownButtonFormField<int>(

                  value: selectedDivisi,

                  decoration: inputStyle("Divisi", Icons.account_tree),

                  items: divisiList.map<DropdownMenuItem<int>>((divisi){

                    return DropdownMenuItem(

                      value: divisi["id_divisi"],
                      child: Text(divisi["nama_divisi"]),

                    );

                  }).toList(),

                  onChanged: (value){

                    setState(() {
                      selectedDivisi = value;
                    });

                  },

                ),

                const SizedBox(height: 30),

                SizedBox(

                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(

                    onPressed: isLoading ? null : register,

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.blue,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                    ),

                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan User",
                            style: TextStyle(fontSize: 18),
                          ),

                  ),

                )

              ],

            ),

          ),

        ),

      ),

    );

  }

}