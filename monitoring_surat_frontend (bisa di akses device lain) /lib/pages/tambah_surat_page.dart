import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class TambahSuratPage extends StatefulWidget {
  const TambahSuratPage({super.key});

  @override
  State<TambahSuratPage> createState() => _TambahSuratPageState();
}

class _TambahSuratPageState extends State<TambahSuratPage> {
  final noSuratController = TextEditingController();
  final dariController = TextEditingController();
  final perihalController = TextEditingController();
  final tanggalSuratController = TextEditingController();
  final tanggalTerimaController = TextEditingController();

  final List<String> jenisSuratList = [
    'Surat Undangan Dinas',
    'Surat Permohonan Dinas',
    'Surat Pemberitahuan Dinas',
    'Surat Edaran',
    'Nota Dinas',
    'Surat Keterangan',
    'Surat Pengantar',
  ];
  String? selectedJenisSurat;

  Uint8List? pdfBytes;
  String? pdfName;
  bool isLoading = false;

  // ================= PICK DATE =================
  Future<void> pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      controller.text = date.toIso8601String().substring(0, 10);
    }
  }

  // ================= PICK PDF =================
  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        pdfBytes = result.files.single.bytes;
        pdfName = result.files.single.name;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> submitSurat() async {
    if (pdfBytes == null || selectedJenisSurat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data')),
      );
      return;
    }

    final token = html.window.localStorage['token'];

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.202:3000/api/surat-masuk'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'no_surat': noSuratController.text,
      'tanggal_surat': tanggalSuratController.text,
      'tanggal_terima': tanggalTerimaController.text,
      'dari': dariController.text,
      'perihal': perihalController.text,
      'jenis_surat': selectedJenisSurat!,
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        'file_surat',
        pdfBytes!,
        filename: pdfName!,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    setState(() => isLoading = true);
    final response = await request.send();
    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Surat berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } else {
      final body = await response.stream.bytesToString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(body)));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Tambah Surat Masuk",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            buildField(noSuratController, "Nomor Surat"),

            // ===== DROPDOWN JENIS SURAT =====
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: selectedJenisSurat,
                decoration: inputDecoration("Jenis Surat"),
                items: jenisSuratList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedJenisSurat = value);
                },
              ),
            ),

            buildDate(tanggalSuratController, "Tanggal Surat"),
            buildDate(tanggalTerimaController, "Tanggal Terima"),
            buildField(dariController, "Dari"),
            buildField(perihalController, "Perihal"),

            const SizedBox(height: 10),

            // ===== UPLOAD PDF =====
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                label: Text(
                  pdfName ?? "Upload File PDF",
                  style: const TextStyle(color: Colors.blue),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: pickPDF,
              ),
            ),

            const SizedBox(height: 20),

            // ===== BUTTON SIMPAN =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : submitSurat,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SIMPAN SURAT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENT =================
  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget buildField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: inputDecoration(label),
      ),
    );
  }

  Widget buildDate(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        readOnly: true,
        onTap: () => pickDate(c),
        decoration: inputDecoration(label),
      ),
    );
  }
}
