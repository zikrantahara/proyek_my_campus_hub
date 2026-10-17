import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'upload_page.dart';
import 'gallery_page.dart';
import 'profile_page.dart';
import 'video_page.dart';
import 'news_page.dart';
import 'contact_page.dart';
import 'schedule_page.dart';
import 'calendar_page.dart';
import 'notification_page.dart';

const Color _navy = Color(0xFF172B68);
const Color _blue = Color(0xFF315CF5);
const Color _purple = Color(0xFF6546E8);
const Color _canvas = Color(0xFFF5F7FF);
const Color _muted = Color(0xFF7C88A8);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    SchedulePage(),
    CalendarPage(),
    NotificationPage(),
  ];

  final List<String> _titles = const [
    'My Campus Hub',
    'Jadwal Kuliah',
    'Kalender Akademik',
    'Notifikasi',
  ];

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.logout_rounded, color: _blue, size: 30),
        title: const Text(
          'Keluar dari akun?',
          style: TextStyle(color: _navy, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Kamu perlu login kembali untuk mengakses My Campus Hub.',
          style: TextStyle(color: _muted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
    );
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_blue, _purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withOpacity(.18),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titles[_selectedIndex],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Your Campus, One Hub',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profil mahasiswa',
            onPressed: _openProfile,
            icon: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFE5EAF8)),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: _navy,
                size: 22,
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu lainnya',
            icon: const Icon(Icons.more_vert_rounded, color: _navy),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'profile') _openProfile();
              if (value == 'gallery') _openPage(const GalleryPage());
              if (value == 'video') _openPage(const VideoPage());
              if (value == 'news') _openPage(const NewsPage());
              if (value == 'contact') _openPage(const ContactPage());
              if (value == 'logout') _logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: _PopupLabel(
                  icon: Icons.person_outline_rounded,
                  label: 'Profil',
                ),
              ),
              PopupMenuItem(
                value: 'gallery',
                child: _PopupLabel(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                ),
              ),
              PopupMenuItem(
                value: 'video',
                child: _PopupLabel(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Video',
                ),
              ),
              PopupMenuItem(
                value: 'news',
                child: _PopupLabel(
                  icon: Icons.newspaper_rounded,
                  label: 'Berita kampus',
                ),
              ),
              PopupMenuItem(
                value: 'contact',
                child: _PopupLabel(
                  icon: Icons.support_agent_rounded,
                  label: 'Kontak person',
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: _PopupLabel(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 5, 14, 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE9EDFA)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF233D86).withOpacity(.09),
                blurRadius: 24,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: NavigationBar(
            height: 66,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor: const Color(0xFFE8EDFF),
            selectedIndex: _selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: _muted),
                selectedIcon: Icon(Icons.home_rounded, color: _blue),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_view_week_outlined, color: _muted),
                selectedIcon: Icon(Icons.calendar_view_week_rounded, color: _blue),
                label: 'Jadwal',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined, color: _muted),
                selectedIcon: Icon(Icons.calendar_month_rounded, color: _blue),
                label: 'Kalender',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded, color: _muted),
                selectedIcon: Icon(Icons.notifications_active_rounded, color: _blue),
                label: 'Notifikasi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PopupLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _navy),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _studentName() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email;
    if (email != null && email.contains('@')) {
      final prefix = email
          .split('@')
          .first
          .replaceAll(RegExp(r'[._-]+'), ' ')
          .trim();

      if (prefix.isNotEmpty) {
        return prefix
            .split(' ')
            .map((word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
      }
    }
    return 'Mahasiswa';
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _studentName();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _WelcomeBanner(name: name),
        const SizedBox(height: 25),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Layanan Mahasiswa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _navy,
                      letterSpacing: -.4,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Semua kebutuhan kampus dalam satu tempat.',
                    style: TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _open(context, const ContactPage()),
              icon: const Icon(Icons.support_agent_rounded, size: 17),
              label: const Text('Bantuan'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 520 ? 3 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 3 ? 1.02 : 1.12,
              children: [
                FeatureCard(
                  icon: Icons.add_a_photo_rounded,
                  title: 'Upload Foto',
                  subtitle: 'Ambil atau pilih foto',
                  iconColor: const Color(0xFF3168F5),
                  onTap: () => _open(
                    context,
                    const UploadPage(type: 'foto', title: 'Upload Foto'),
                  ),
                ),
                FeatureCard(
                  icon: Icons.photo_library_rounded,
                  title: 'Galeri',
                  subtitle: 'Lihat foto tersimpan',
                  iconColor: const Color(0xFF8855E9),
                  onTap: () => _open(context, const GalleryPage()),
                ),
                FeatureCard(
                  icon: Icons.badge_rounded,
                  title: 'Upload KTP',
                  subtitle: 'Simpan dokumen KTP',
                  iconColor: const Color(0xFFF05C85),
                  onTap: () => _open(
                    context,
                    const UploadPage(type: 'ktp', title: 'Upload KTP'),
                  ),
                ),
                FeatureCard(
                  icon: Icons.credit_card_rounded,
                  title: 'Upload KTM',
                  subtitle: 'Simpan dokumen KTM',
                  iconColor: const Color(0xFFF39B36),
                  onTap: () => _open(
                    context,
                    const UploadPage(type: 'ktm', title: 'Upload KTM'),
                  ),
                ),
                FeatureCard(
                  icon: Icons.person_rounded,
                  title: 'Profil',
                  subtitle: 'Kelola data diri',
                  iconColor: const Color(0xFF16A982),
                  onTap: () => _open(context, const ProfilePage()),
                ),
                FeatureCard(
                  icon: Icons.play_circle_fill_rounded,
                  title: 'Video',
                  subtitle: 'Materi pembelajaran',
                  iconColor: const Color(0xFF299DDA),
                  onTap: () => _open(context, const VideoPage()),
                ),
                FeatureCard(
                  icon: Icons.newspaper_rounded,
                  title: 'Berita Kampus',
                  subtitle: 'Informasi terbaru',
                  iconColor: const Color(0xFF5367D8),
                  onTap: () => _open(context, const NewsPage()),
                ),
                FeatureCard(
                  icon: Icons.support_agent_rounded,
                  title: 'Kontak Person',
                  subtitle: 'Hubungi admin kampus',
                  iconColor: const Color(0xFF14A5A5),
                  onTap: () => _open(context, const ContactPage()),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Informasi Terbaru',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: _navy,
                  letterSpacing: -.3,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _open(context, const NewsPage()),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          child: InkWell(
            borderRadius: BorderRadius.circular(21),
            onTap: () => _open(context, const NewsPage()),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: const Color(0xFFE8ECF6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFFEF8738),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengumuman kampus',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: _navy,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Buka halaman berita untuk melihat informasi dan pengumuman.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.45,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: _muted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, color: _blue, size: 21),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tips: gunakan kalender dan notifikasi untuk membantu mengingat jadwal kuliah serta tenggat tugas.',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String name;

  const _WelcomeBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue, Color(0xFF4D54E8), _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -20,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Halo,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Selamat datang kembali 👋',
                          style: TextStyle(
                            color: Color(0xE0FFFFFF),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: Colors.white.withOpacity(.15)),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 39,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(.12)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Tetap semangat meraih masa depan bersama kampus!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = _blue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8ECF6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
