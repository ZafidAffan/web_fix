import 'dart:convert';
import 'dart:html' as html; // Flutter Web localStorage
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisposisiSuratPage extends StatefulWidget {
  const DisposisiSuratPage({super.key});

  @override
  State<DisposisiSuratPage> createState() => _DisposisiSuratPageState();
}

class _DisposisiSuratPageState extends State<DisposisiSuratPage> {
  List suratList = [];
  List<Map<String, dynamic>> divisiList = []; // id + nama divisi
  bool isLoading = true;

  int? selectedDivisiId; // untuk dropdown

  @override
  void initState() {
    super.initState();
    fetchSurat();
    fetchDivisi();
  }

  // ================= FETCH SURAT =================
  Future<void> fetchSurat() async {
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.202:3000/api/surat-masuk'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          suratList = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Gagal fetch surat: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetch surat: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= FETCH DIVISI =================
  Future<void> fetchDivisi() async {
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/api/disposisi/divisi'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          divisiList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        print("Gagal fetch divisi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetch divisi: $e");
    }
  }

  // ================= DIALOG DISPOSISI =================
  void showDisposisiDialog(Map surat) {
    selectedDivisiId = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Disposisi Surat"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                surat['perihal'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Pilih Divisi',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: divisiList.map((divisi) {
                  return DropdownMenuItem<int>(
                    value: divisi['id_divisi'],
                    child: Text(divisi['nama_divisi']),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedDivisiId = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Kirim Disposisi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF347433),
              ),
              onPressed: () async {
                if (selectedDivisiId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pilih divisi dulu")),
                  );
                  return;
                }

                final token = html.window.localStorage['token'];

                try {
                  final response = await http.post(
                    Uri.parse('http://127.0.0.1:3000/api/disposisi/tambah-umum'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'id_surat': surat['id_surat'],
                      'ke_divisi': selectedDivisiId,
                      'perintah': 'Disposisi', // default umum
                      'keterangan': '',
                      'status_proses': 'menunggu_divisi', // status untuk umum
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil mengirim disposisi")),
                    );
                    fetchSurat();
                  } else {
                    print("Gagal disposisi: ${response.body}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal disposisi, coba lagi")),
                    );
                  }
                } catch (e) {
                  print("Exception disposisi: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal menghubungi server")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0CD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF347433),
        title: const Text(
          "Disposisi Surat Masuk",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suratList.length,
              itemBuilder: (context, index) {
                final surat = suratList[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surat['no_surat'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Dari: ${surat['dari']}"),
                        Text("Perihal: ${surat['perihal']}"),
                        Text("Status: ${surat['status']}"),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => showDisposisiDialog(surat),
                            icon: const Icon(Icons.send),
                            label: const Text("Disposisi"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF347433),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
