import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SuratDariKepalaPage extends StatefulWidget {
  const SuratDariKepalaPage({super.key});

  @override
  State<SuratDariKepalaPage> createState() => _SuratDariKepalaPageState();
}

class _SuratDariKepalaPageState extends State<SuratDariKepalaPage> {
  List disposisiList = [];
  bool isLoading = true;

  final Color bgColor = const Color(0xFFF5F0CD); // kuning lembut
  final Color primaryColor = const Color(0xFF347433); // hijau tua

  @override
  void initState() {
    super.initState();
    fetchDisposisi();
  }

  // ================= FETCH DISPOSISI =================
  Future<void> fetchDisposisi() async {
    final token = html.window.localStorage['token'];
    if (token == null) {
      debugPrint("Token tidak ditemukan");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.202:3000/api/disposisi/umum/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List allDisposisi = jsonDecode(response.body);
        setState(() {
          disposisiList = allDisposisi
              .where((d) => d['status_proses'] == 'menunggu_umum')
              .toList();
          isLoading = false;
        });
      } else {
        debugPrint("Gagal fetch disposisi: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetch disposisi: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= KONFIRMASI TERIMA =================
  Future<void> konfirmasiDisposisi(int idDisposisi) async {
    final token = html.window.localStorage['token'];
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            'http://127.0.0.1:3000/api/disposisi/umum/$idDisposisi/konfirmasi'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disposisi berhasil dikonfirmasi!')),
        );
        fetchDisposisi(); // refresh list
      } else {
        debugPrint('Gagal konfirmasi disposisi: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal konfirmasi disposisi')),
        );
      }
    } catch (e) {
      debugPrint('Error konfirmasi disposisi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Surat dari Kepala'),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : disposisiList.isEmpty
              ? const Center(child: Text('Tidak ada disposisi menunggu Umum'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: disposisiList.length,
                  itemBuilder: (context, index) {
                    final disposisi = disposisiList[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID Disposisi: ${disposisi['id_disposisi']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text('ID Surat: ${disposisi['id_surat']}'),
                            Text('Dari User: ${disposisi['dari_user']}'),
                            Text('Perintah: ${disposisi['perintah']}'),
                            Text('Keterangan: ${disposisi['keterangan']}'),
                            Text(
                                'Tanggal Disposisi: ${disposisi['tanggal_disposisi']}'),
                            Text(
                                'Status Konfirmasi: ${disposisi['status_konfirmasi']}'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => konfirmasiDisposisi(
                                  disposisi['id_disposisi']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Konfirmasi Terima',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
