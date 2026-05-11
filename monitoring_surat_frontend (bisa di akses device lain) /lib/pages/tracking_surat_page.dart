import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'detail_tracking_surat_page.dart';

class TrackingSuratPage extends StatefulWidget {
  const TrackingSuratPage({super.key});

  @override
  State<TrackingSuratPage> createState() => _TrackingSuratPageState();
}

class _TrackingSuratPageState extends State<TrackingSuratPage> {
  List suratList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSuratMasuk();
  }

  // ================= FETCH SURAT MASUK =================
  Future<void> fetchSuratMasuk() async {
    final token = html.window.localStorage['token'];

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http:/192.168.1.202:3000/api/surat-masuk"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          suratList = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= WARNA STATUS =================
  Color statusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Diterima':
        return Colors.blue;
      case 'Disposisi Kepala':
        return Colors.purple;
      case 'Disposisi Divisi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Tracking Surat",
          style: TextStyle(color: Colors.white),
        ),

        // ✅ BACK FIX — BALIK KE DASHBOARD
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
             Navigator.pop(context);
          },
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : suratList.isEmpty
              ? const Center(child: Text("Tidak ada surat masuk"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suratList.length,
                  itemBuilder: (context, index) {
                    final surat = suratList[index];
                    final status = surat['status'] ?? '-';

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailTrackingSuratPage(
                                idSurat: surat['id_surat'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ================= HEADER =================
                              Row(
                                children: [
                                  const Icon(
                                    Icons.mail,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      surat['no_surat'] ?? 'Tanpa Nomor',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor(status)
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: statusColor(status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              const Divider(),

                              // ================= KETERANGAN =================
                              infoRow(
                                "Jenis Surat",
                                surat['jenis_surat'],
                              ),
                              infoRow(
                                "Dari",
                                surat['dari'],
                              ),
                              infoRow(
                                "Perihal",
                                surat['perihal'],
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // ================= INFO ROW =================
  Widget infoRow(String label, dynamic value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              "$label :",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
