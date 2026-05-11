import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalSuratMasuk = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSuratMasuk();
  }

  Future<void> fetchSuratMasuk() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.202:3000/api/surat-masuk/count"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          totalSuratMasuk = data["total"];
          loading = false;
        });
      }
    } catch (e) {
      print("Error API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Dashboard Monitoring Surat",
          style: TextStyle(color: Colors.white),
        ),
      ),

      drawer: Drawer(
        child: Container(
          color: Colors.blue,
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),

              buildMenuItem(Icons.dashboard, "Dashboard", () {
                Navigator.pop(context);
              }),



              buildMenuItem(Icons.sync_alt, "Tracking Surat", () {
                Navigator.pushNamed(context, "/tracking-surat");
              }),

              buildMenuItem(Icons.logout, "Logout", () {
                Navigator.pushReplacementNamed(context, "/login");
              }),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/gedung.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari data surat...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  buildDashboardCard(
                    "Surat Masuk",
                    loading ? "..." : totalSuratMasuk.toString(),
                    Icons.mail,
                    Colors.green,
                  ),
                  buildDashboardCard(
                    "Surat Diproses",
                    "—",
                    Icons.sync,
                    Colors.orange,
                  ),
                  buildDashboardCard(
                    "Surat Selesai",
                    "—",
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String label, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget buildDashboardCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 35, color: color),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
