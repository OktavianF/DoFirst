import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Frequently Asked Questions (FAQ)'),
            const SizedBox(height: 12),
            _buildBulletItem(
              'Bagaimana cara kerja Focus Mode? Focus Mode membantu Anda meminimalkan gangguan dengan mengatur interval waktu kerja dan istirahat yang bisa dikustomisasi melalui menu Focus & Break Settings.',
            ),
            const SizedBox(height: 8),
            _buildBulletItem(
              'Bagaimana cara menyambungkan Google Calendar? Buka menu Google Sync di halaman profil, lalu ketuk tombol "Connect" untuk mengaktifkan sinkronisasi otomatis jadwal Anda.',
            ),
            const SizedBox(height: 8),
            _buildBulletItem(
              'Apakah data tugas saya aman? Ya, semua data tugas dan jadwal yang Anda masukkan bersifat pribadi dan dilindungi sesuai dengan kebijakan privasi kami.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Hubungi Kami'),
            const SizedBox(height: 12),
            _buildBulletItem(
              'Live Chat Support Butuh bantuan cepat? Tim kami tersedia untuk membantu masalah teknis atau pertanyaan fitur secara real-time.',
            ),
            const SizedBox(height: 8),
            _buildBulletItem(
              'Kirim Email Jika Anda memiliki pertanyaan yang lebih mendetail, silakan kirimkan pesan ke: support@dofirst.app',
            ),
            const SizedBox(height: 8),
            _buildBulletItem(
              'Laporkan Masalah (Report a Bug) Menemukan kendala teknis? Kirimkan laporan singkat beserta tangkapan layar agar tim pengembang kami bisa segera memperbaikinya.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Pusat Informasi'),
            const SizedBox(height: 12),
            _buildBulletItem(
              'Panduan Pengguna Pelajari cara memaksimalkan fitur produktivitas DoFirst mulai dari manajemen tugas hingga analisis waktu fokus.',
            ),
            const SizedBox(height: 8),
            _buildBulletItem(
              'Status Layanan Cek ketersediaan server dan pembaruan sistem secara berkala untuk memastikan pengalaman sinkronisasi yang lancar.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search help...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 12, top: 2),
          child: Text(
            '•',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
