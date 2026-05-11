import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisposisiKepalaPage extends StatefulWidget {
  final Map surat;

  const DisposisiKepalaPage({super.key, required this.surat});

  @override
  State<DisposisiKepalaPage> createState() => _DisposisiKepalaPageState();
}

class _DisposisiKepalaPageState extends State<DisposisiKepalaPage> {
  final TextEditingController perintahController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  List<Map<String, dynamic>> templatePerintah = [];
  List<Map<String, dynamic>> divisiList = [];

  String? selectedTemplate;
  int? selectedDivisiId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTemplatePerintah();
    fetchDivisi();
  }

  // ================= FETCH TEMPLATE =================
  Future<void> fetchTemplatePerintah() async {
    final token = html.window.localStorage['token'];

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.202:3000/api/template-perintah'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          templatePerintah =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      debugPrint('❌ fetchTemplatePerintah error: $e');
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
          divisiList =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      debugPrint('❌ fetchDivisi error: $e');
    }
  }

  // ================= SUBMIT DISPOSISI =================
  Future<void> submitDisposisi() async {
    final token = html.window.localStorage['token'];

    final perintahFinal =
        selectedTemplate?.trim() ?? perintahController.text.trim();

    if (perintahFinal.isEmpty || selectedDivisiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perintah & divisi wajib diisi')),
      );
      return;
    }

    setState(() => isLoading = true);

    // 🔍 DEBUG DATA YANG DIKIRIM
    debugPrint('📤 KIRIM DISPOSISI:');
    debugPrint('id_surat   : ${widget.surat['id_surat']}');
    debugPrint('ke_divisi  : $selectedDivisiId');
    debugPrint('perintah   : $perintahFinal');
    debugPrint('keterangan : ${keteranganController.text}');

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/disposisi/kepala'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_surat': widget.surat['id_surat'],
          'ke_divisi': selectedDivisiId, // ✅ FIX UTAMA
          'perintah': perintahFinal,
          'keterangan': keteranganController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disposisi berhasil dikirim')),
        );
        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mengirim disposisi'),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final surat = widget.surat;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0CD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF347433),
        title: const Text(
          'Disposisi Kepala',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= INFO SURAT =================
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surat['no_surat'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Dari: ${surat['dari']}'),
                    Text('Perihal: ${surat['perihal']}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= TEMPLATE =================
            const Text('Template Perintah',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedTemplate,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Pilih template'),
              items: templatePerintah.map((t) {
                return DropdownMenuItem<String>(
                  value: t['isi_perintah'],
                  child: Text(t['isi_perintah']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTemplate = value;
                  perintahController.clear();
                });
              },
            ),

            const SizedBox(height: 16),

            // ================= MANUAL =================
            const Text('Atau Isi Manual',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: perintahController,
              maxLines: 3,
              onChanged: (_) {
                if (selectedTemplate != null) {
                  setState(() => selectedTemplate = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'Tulis perintah...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            // ================= DIVISI =================
            const Text('Pilih Divisi Tujuan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedDivisiId,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Pilih divisi'),
              items: divisiList.map((d) {
                return DropdownMenuItem<int>(
                  value: d['id_divisi'], // ✅ INT ASLI
                  child: Text(d['nama_divisi']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedDivisiId = value);
              },
            ),

            const SizedBox(height: 16),

            // ================= KETERANGAN =================
            const Text('Keterangan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: keteranganController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Keterangan tambahan...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 32),

            // ================= SUBMIT =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitDisposisi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF347433),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim Disposisi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
