import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardUmumPage extends StatefulWidget {
  const DashboardUmumPage({super.key});

  @override
  State<DashboardUmumPage> createState() => _DashboardUmumPageState();
}

class _DashboardUmumPageState extends State<DashboardUmumPage> {
  List suratList = [];
  bool isLoading = true;
  String searchQuery = '';

  // 🔥 LINK SPREADSHEET (GLOBAL)
  final String spreadsheetUrl =
      'https://docs.google.com/spreadsheets/d/151zzZ9WM9p1OTP8LUXkPHPu5kK4hFmRkdKaLwBG-o9U/edit?gid=0#gid=0';

  @override
  void initState() {
    super.initState();
    fetchSurat();
  }

  // ================= FETCH SURAT =================
  Future<void> fetchSurat({String? search}) async {
    setState(() => isLoading = true);
    final token = html.window.localStorage['token'];

    try {
      String url = 'http://192.168.1.202:3000/api/surat-masuk';
      if (search != null && search.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          suratList = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetch surat: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= TERIMA =================
  Future<void> terimaSurat(int idSurat) async {
    final token = html.window.localStorage['token'];

    await http.put(
      Uri.parse('http://127.0.0.1:3000/api/aksi/$idSurat/terima'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    fetchSurat(search: searchQuery);
  }

  // ================= KIRIM KE KEPALA =================
  Future<void> kirimKeKepala(int idSurat) async {
    final token = html.window.localStorage['token'];

    await http.put(
      Uri.parse('http://127.0.0.1:3000/api/aksi/$idSurat/kirim-ke-kepala'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    fetchSurat(search: searchQuery);
  }

  // ================= 🔥 BUKA SPREADSHEET =================
  Future<void> printDisposisi(int idSurat) async {
    html.window.open(spreadsheetUrl, '_blank');
  }

  // ================= LOGOUT =================
  void logout() {
    html.window.localStorage.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Dashboard Umum",
          style: TextStyle(color: Colors.white),
        ),
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        child: Container(
          color: Colors.blue,
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  "Menu Umum",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              buildMenuItem(Icons.dashboard, "Dashboard", () {
                Navigator.pop(context);
              }),
              buildMenuItem(Icons.add_circle, "Tambah Surat", () {
                Navigator.pushNamed(context, "/tambah-surat");
              }),
              buildMenuItem(Icons.sync_alt, "Tracking Surat", () {
                Navigator.pushNamed(context, "/tracking-surat");
              }),
              buildMenuItem(Icons.person_add, "Register User", () {
                Navigator.pushNamed(context, "/register");
              }),
              buildMenuItem(Icons.logout, "Logout", logout),
            ],
          ),
        ),
      ),

      // ================= BODY =================
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

                  // 🔍 SEARCH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari surat...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (query) {
                        searchQuery = query;
                        fetchSurat(search: query);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= LIST SURAT =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: suratList.map((surat) {
                        final status = surat['status'];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // HEADER
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      surat['no_surat'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye),
                                      color: Colors.blue,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/detail-surat',
                                          arguments: surat,
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Text("Jenis Surat : ${surat['jenis_surat']}"),
                                Text("Dari        : ${surat['dari']}"),
                                Text(
                                  "Perihal     : ${surat['perihal']}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Status      : $status",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 12),

                                // ================= BUTTON =================
                                Row(
                                  children: [
                                    if (status == 'Menunggu')
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text('Terima'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () =>
                                            terimaSurat(surat['id_surat']),
                                      ),

                                    const SizedBox(width: 8),

                                    if (status == 'Diterima')
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.send),
                                        label:
                                            const Text('Kirim ke Kepala'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        onPressed: () =>
                                            kirimKeKepala(surat['id_surat']),
                                      ),

                                    const SizedBox(width: 8),

                                    if (status == 'Disposisi Divisi')
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.table_view),
                                        label: const Text('Buka Spreadsheet'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            printDisposisi(surat['id_surat']),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildMenuItem(
      IconData icon, String label, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title:
          Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}