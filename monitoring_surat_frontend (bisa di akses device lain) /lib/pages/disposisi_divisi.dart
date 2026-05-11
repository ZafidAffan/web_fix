import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DisposisiDivisiPage extends StatefulWidget {
  final int idDisposisi;
  final int idDivisi;

  const DisposisiDivisiPage({
    super.key,
    required this.idDisposisi,
    required this.idDivisi,
  });

  @override
  State<DisposisiDivisiPage> createState() => _DisposisiDivisiPageState();
}

class _DisposisiDivisiPageState extends State<DisposisiDivisiPage> {
  bool loading = true;
  List<dynamic> subDivisiList = [];
  int? selectedSubDivisi;

  final TextEditingController keteranganController = TextEditingController();

  // ================= FETCH SUB DIVISI =================
  Future<void> fetchSubDivisi() async {
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.202:3000/api/disposisi/divisi/${widget.idDivisi}/subdivisi',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      setState(() {
        if (response.statusCode == 200) {
          subDivisiList = jsonDecode(response.body);
        }
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  // ================= SUBMIT DISPOSISI =================
  Future<void> submitDisposisi() async {
    if (selectedSubDivisi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih sub divisi terlebih dahulu')),
      );
      return;
    }

    final token = html.window.localStorage['token'];

    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost:3000/api/disposisi/${widget.idDisposisi}/subdivisi',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ke_divisi_sub': selectedSubDivisi,
          'keterangan': keteranganController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disposisi berhasil diteruskan')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim disposisi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan koneksi')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSubDivisi();
  }

  String formatTanggal(DateTime date) {
    return DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text(
          'Disposisi ke Sub Divisi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= INFO CARD =================
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Disposisi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(),
                          buildRow('ID Disposisi', widget.idDisposisi.toString()),
                          buildRow('Tanggal', formatTanggal(DateTime.now())),
                          buildRow('Status', 'Disposisi Divisi'),
                        ],
                      ),
                    ),
                  ),

                  // ================= FORM CARD =================
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Form Disposisi Sub Divisi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),

                          // ===== DROPDOWN SUB DIVISI =====
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Tujuan Sub Divisi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            value: selectedSubDivisi,
                            isExpanded: true,
                            items: subDivisiList.map<DropdownMenuItem<int>>((sub) {
                              return DropdownMenuItem<int>(
                                value: sub['id_subdivisi'],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub['nama_subdivisi'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    if (sub['keterangan'] != null &&
                                        sub['keterangan'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          sub['keterangan'],
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSubDivisi = value;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // ===== KETERANGAN =====
                          TextField(
                            controller: keteranganController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Keterangan / Instruksi',
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ===== SUBMIT BUTTON =====
                          ElevatedButton.icon(
                            onPressed: submitDisposisi,
                            icon: const Icon(Icons.send),
                            label: const Text('Kirim ke Sub Divisi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
