import 'dart:convert';
import 'dart:html' as html; // Untuk Flutter Web localStorage & window.open
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'disposisi_divisi.dart';

class DashboardDivisiPage extends StatefulWidget {
  const DashboardDivisiPage({super.key});

  @override
  State<DashboardDivisiPage> createState() => _DashboardDivisiPageState();
}

class _DashboardDivisiPageState extends State<DashboardDivisiPage> {
  List disposisiList = [];
  bool loading = true;
  int divisiId = 0;

  @override
  void initState() {
    super.initState();
    _getDivisiIdFromToken();
    fetchDisposisiDivisi();
  }

  // ================= AMBIL ID DIVISI DARI TOKEN =================
  void _getDivisiIdFromToken() {
    final token = html.window.localStorage['token'];
    if (token != null && token.isNotEmpty) {
      final payload = token.split('.')[1];
      final decoded =
          utf8.decode(base64Url.decode(base64Url.normalize(payload)));
      final data = json.decode(decoded);
      divisiId = data['divisi'] ?? 0;
    }
  }

  // ================= FETCH DISPOSISI DIVISI =================
  Future<void> fetchDisposisiDivisi() async {
    setState(() => loading = true);
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.202:3000/api/disposisi/divisi/$divisiId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          disposisiList = data;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil data disposisi: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ================= TERIMA DISPOSISI =================
  Future<void> terimaDisposisi(int idDisposisi) async {
    final token = html.window.localStorage['token'];

    final response = await http.put(
      Uri.parse('http://localhost:3000/api/disposisi/$idDisposisi/konfirmasi-divisi'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      fetchDisposisiDivisi();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disposisi berhasil diterima')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terima disposisi: ${response.statusCode}')),
      );
    }
  }

  // ================= LOGOUT =================
  void logout() {
    html.window.localStorage.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ================= FORMAT TANGGAL =================
  String formatTanggal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  // ================= LIHAT SURAT =================
  void lihatSurat(String? filePath) {
    if (filePath != null && filePath.isNotEmpty) {
      // Tambahkan base URL server
      final url = 'http://localhost:3000$filePath';
      html.window.open(url, '_blank');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File tidak tersedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Divisi'),
        backgroundColor: Colors.green[700],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.green[700],
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  'Menu Divisi',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : disposisiList.isEmpty
              ? const Center(child: Text('Tidak ada disposisi masuk'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: disposisiList.length,
                  itemBuilder: (context, index) {
                    final d = disposisiList[index];
                    final sudahDiterima = d['status_konfirmasi'] == 'diterima';
                    final statusProses = d['status_proses'] ?? '';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['no_surat'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),

                            infoRow('Dari', d['dari']),
                            infoRow('Perihal', d['perihal']),
                            infoRow('Jenis Surat', d['jenis_surat']),
                            infoRow(
                                'Tanggal', formatTanggal(d['tanggal_disposisi'])),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                // Tombol lihat surat
                                ElevatedButton(
                                  onPressed: () => lihatSurat(d['file_surat']),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  child: const Text('Lihat Surat'),
                                ),
                                const SizedBox(width: 12),

                                // Tombol atau label disposisi
                                Expanded(
                                  child: statusProses == 'selesai'
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Selesai',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      : sudahDiterima
                                          ? OutlinedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        DisposisiDivisiPage(
                                                      idDisposisi:
                                                          d['id_disposisi'],
                                                      idDivisi: d['ke_divisi'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                  'Kirim ke Sub Divisi'),
                                            )
                                          : ElevatedButton(
                                              onPressed: () => terimaDisposisi(
                                                  d['id_disposisi']),
                                              child:
                                                  const Text('Terima Disposisi'),
                                            ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child:
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Text(': '),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }
}
