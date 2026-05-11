import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ================= DASHBOARD KEPALA PAGE =================
class DashboardKepalaPage extends StatefulWidget {
  const DashboardKepalaPage({super.key});

  @override
  State<DashboardKepalaPage> createState() => _DashboardKepalaPageState();
}

class _DashboardKepalaPageState extends State<DashboardKepalaPage> {
  List suratList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuratDisposisiKepala();
  }

  // ================= FETCH SURAT =================
  Future<void> fetchSuratDisposisiKepala() async {
    setState(() => isLoading = true);
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.202:3000/api/surat-masuk'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List allSurat = jsonDecode(response.body);
        setState(() {
          // Hanya surat yang statusnya "Disposisi Kepala"
          suratList = allSurat
              .where((s) => s['status'] == 'Disposisi Kepala')
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetch surat disposisi kepala: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= WARNA STATUS =================
  Color statusColor(String status) {
    switch (status) {
      case 'Disposisi Kepala':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
        backgroundColor: Colors.green[700],
        title: const Text(
          'Dashboard Kepala',
          style: TextStyle(color: Colors.white),
        ),
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        child: Container(
          color: Colors.green[700],
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  'Menu Kepala',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              buildMenuItem(Icons.dashboard, 'Dashboard', () {
                Navigator.pop(context);
              }),
              buildMenuItem(Icons.mail, 'Surat Masuk', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SuratMasukKepalaPage()),
                );
              }),
              buildMenuItem(Icons.logout, 'Logout', logout),
            ],
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suratList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada surat disposisi untuk kepala',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // ================= HEADER IMAGE =================
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
                      const SizedBox(height: 20),

                      // ================= LIST SURAT =================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: suratList.map((surat) {
                            final status = surat['status'];
                            final color = statusColor(status);

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            surat['no_surat'] ?? '-',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye),
                                          color: Colors.blue,
                                          tooltip: 'Lihat Detail',
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/detail-surat',
                                              arguments: surat,
                                            );
                                          },
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Dari    : ${surat['dari']}'),
                                    Text(
                                      'Perihal : ${surat['perihal']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 14),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.assignment),
                                        label: const Text('Beri Instruksi'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/disposisi-kepala',
                                            arguments: surat,
                                          );
                                        },
                                      ),
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

  Widget buildMenuItem(IconData icon, String label, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

// ================= SURAT MASUK KEPALA PAGE =================
class SuratMasukKepalaPage extends StatefulWidget {
  const SuratMasukKepalaPage({super.key});

  @override
  State<SuratMasukKepalaPage> createState() => _SuratMasukKepalaPageState();
}

class _SuratMasukKepalaPageState extends State<SuratMasukKepalaPage> {
  List suratList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuratMasuk();
  }

  Future<void> fetchSuratMasuk() async {
    setState(() => isLoading = true);
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/api/surat-masuk'),
        headers: {'Authorization': 'Bearer $token'},
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
      debugPrint("Error fetch surat masuk: $e");
      setState(() => isLoading = false);
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Diterima':
        return Colors.green;
      case 'Disposisi Kepala':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surat Masuk Kepala'),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suratList.isEmpty
              ? const Center(child: Text('Tidak ada surat masuk'))
              : SingleChildScrollView(
                  child: Column(
                    children: suratList.map((surat) {
                      final color = statusColor(surat['status']);
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(surat['no_surat'] ?? '-'),
                          subtitle: Text('Dari: ${surat['dari']}\nPerihal: ${surat['perihal']}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              surat['status'],
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/detail-surat', arguments: surat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
