import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailTrackingSuratPage extends StatefulWidget {
  final int idSurat;

  const DetailTrackingSuratPage({
    super.key,
    required this.idSurat,
  });

  @override
  State<DetailTrackingSuratPage> createState() =>
      _DetailTrackingSuratPageState();
}

class _DetailTrackingSuratPageState extends State<DetailTrackingSuratPage> {
  List trackingList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTracking();
  }

  // ================= FETCH TRACKING =================
  Future<void> fetchTracking() async {
    final token = html.window.localStorage['token'];

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token tidak ditemukan, silakan login ulang"),
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.1.202:3000/api/tracking/surat/${widget.idSurat}",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          trackingList = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= FORMAT WAKTU =================
  String formatWaktu(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();

      const bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];

      final tanggal =
          "${dt.day.toString().padLeft(2, '0')} ${bulan[dt.month - 1]} ${dt.year}";
      final jam =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

      return "$tanggal • $jam WIB";
    } catch (e) {
      return rawDate;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Detail Tracking Surat",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : trackingList.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada riwayat tracking",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trackingList.length,
                  itemBuilder: (context, index) {
                    final item = trackingList[index];
                    final isLast = index == trackingList.length - 1;

                    // ================= LEVEL =================
                    // Menjorok ke kanan jika status mengandung "Sub Divisi"
                    final level = item['status']
                                .toString()
                                .toLowerCase()
                                .contains('sub divisi')
                            ? 1
                            : 0;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ================= TIMELINE =================
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 14),

                          // ================= CARD =================
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: level * 60.0),
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // STATUS
                                      Text(
                                        item['status'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      // NAMA DIVISI
                                      if (item['nama_divisi'] != null &&
                                          item['nama_divisi'].toString().isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            item['nama_divisi'],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 6),

                                      // KETERANGAN
                                      if (item['keterangan'] != null &&
                                          item['keterangan']
                                              .toString()
                                              .isNotEmpty)
                                        Text(
                                          item['keterangan'],
                                          style: const TextStyle(
                                              color: Colors.black87),
                                          softWrap: true,
                                        ),

                                      const SizedBox(height: 10),

                                      // WAKTU
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            formatWaktu(item['waktu']),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
