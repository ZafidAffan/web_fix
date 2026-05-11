import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// ===== IMPORT SEMUA PAGE =====
import 'pages/login.dart';
import 'pages/dashboard_page.dart';
import 'pages/tambah_surat_page.dart';
import 'pages/divisi_dashboard_page.dart';
import 'pages/umum_dashboard_page.dart';
import 'pages/disposisi_surat_page.dart';
import 'pages/dashboard_kepala.dart';
import 'pages/disposisi_kepala.dart';
import 'pages/surat_dari_kepala.dart';
import 'pages/tracking_surat_page.dart';
import 'pages/detail_surat_page.dart';
import 'pages/register_page.dart';

/// =======================
/// MAIN (WAJIB ASYNC!)
/// =======================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 INI YANG FIX ERROR MERAH intl
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Monitoring Surat BNN",

      // ===== HALAMAN AWAL =====
      initialRoute: "/login",

      // ===== ROUTING TANPA ARGUMENT =====
      routes: {
        // ================= AUTH =================
        "/login": (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // ================= ADMIN =================
        "/dashboard": (context) => const DashboardPage(),
        "/tambah-surat": (context) => const TambahSuratPage(),
        "/disposisi-surat": (context) => const DisposisiSuratPage(),

        // ================= DIVISI =================
        "/divisi": (context) => const DashboardDivisiPage(),

        // ================= UMUM =================
        "/umum": (context) => const DashboardUmumPage(),

        // ================= KEPALA =================
        "/kepala": (context) => const DashboardKepalaPage(),

        // ================= LAINNYA =================
        "/surat-dari-kepala": (context) => const SuratDariKepalaPage(),
        "/tracking-surat": (context) => const TrackingSuratPage(),
      },

      // ===== ROUTE DENGAN ARGUMENT =====
      onGenerateRoute: (settings) {
        // DISPOSISI KEPALA
        if (settings.name == '/disposisi-kepala') {
          final surat = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DisposisiKepalaPage(surat: surat),
          );
        }

        // DETAIL SURAT
        if (settings.name == '/detail-surat') {
          final surat = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DetailSuratPage(surat: surat),
          );
        }

        return null;
      },
    );
  }
}
