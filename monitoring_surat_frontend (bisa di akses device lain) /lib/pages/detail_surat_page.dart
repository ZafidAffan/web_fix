import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailSuratPage extends StatelessWidget {
  final Map surat;

  const DetailSuratPage({super.key, required this.surat});

  // ================= ROLE =================
  String? get role => html.window.localStorage['role'];
  bool get isUmum => role == 'umum';

  // ================= FORMAT TANGGAL =================
  String formatTanggal(dynamic value) {
    if (value == null) return '-';

    try {
      final dateTime = DateTime.parse(value.toString()).toLocal();

      final tanggal =
          "${dateTime.day.toString().padLeft(2, '0')} "
          "${_bulan(dateTime.month)} "
          "${dateTime.year}";

      final jam =
          "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}";

      return "$tanggal • $jam WIB";
    } catch (e) {
      return value.toString();
    }
  }

  String _bulan(int bulan) {
    const listBulan = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return listBulan[bulan];
  }

  // ================= LIHAT PDF =================
  void lihatPDF() {
    final url = "http://192.168.1.202:3000${surat['file_surat']}";
    html.window.open(url, "_blank");
  }

  // ================= HAPUS SURAT =================
  Future<void> hapusSurat(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Surat"),
        content: const Text("Yakin ingin menghapus surat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse(
          "http://localhost:3000/api/surat-masuk/${surat['id_surat']}",
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Surat berhasil dihapus")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus surat")),
        );
      }
    } catch (e) {
      debugPrint("Error hapus surat: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Detail Surat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailItem("No Surat", surat['no_surat']),
                detailItem("Jenis Surat", surat['jenis_surat']),
                detailItem("Tanggal Surat",
                    formatTanggal(surat['tanggal_surat'])),
                detailItem("Tanggal Terima",
                    formatTanggal(surat['tanggal_terima'])),

                const Divider(height: 30),

                detailItem("Dari", surat['dari']),
                detailItem("Perihal", surat['perihal'], bold: true),

                const Divider(height: 30),

                detailItem("Status", surat['status']),
                detailItem("Diinput",
                    formatTanggal(surat['created_at'])),

                const SizedBox(height: 30),

                // ================= ACTION BUTTON =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // PDF → SEMUA ROLE
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Lihat PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: lihatPDF,
                    ),

                    // EDIT & HAPUS → KHUSUS UMUM
                    if (isUmum)
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/edit-surat",
                                arguments: surat,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text("Hapus"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => hapusSurat(context),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= ITEM DETAIL =================
  Widget detailItem(String label, dynamic value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? "-",
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
