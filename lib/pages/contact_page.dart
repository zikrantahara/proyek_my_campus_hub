import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  static const Color _blue = Color(0xFF315CF5);
  static const Color _purple = Color(0xFF6546E8);
  static const Color _ink = Color(0xFF172B68);
  static const Color _muted = Color(0xFF7C88A8);
  static const Color _canvas = Color(0xFFF5F7FF);

  // Ganti informasi contoh di bawah dengan kontak resmi milik kampusmu.
  final List<_ContactItem> _contacts = const [
    _ContactItem(
      name: 'Layanan Akademik',
      role: 'Informasi perkuliahan dan administrasi',
      icon: Icons.school_rounded,
      color: Color(0xFF315CF5),
      value: 'https://www.kemdikbud.go.id/',
      action: 'website',
    ),
    _ContactItem(
      name: 'Bantuan Teknologi',
      role: 'Bantuan aplikasi dan kendala teknis',
      icon: Icons.support_agent_rounded,
      color: Color(0xFF6546E8),
      value: 'mailto:helpdesk@example.com',
      action: 'email',
    ),
    _ContactItem(
      name: 'Sekretariat Kampus',
      role: 'Pertanyaan umum dan informasi kampus',
      icon: Icons.apartment_rounded,
      color: Color(0xFF0D9488),
      value: 'https://www.kemdikbud.go.id/',
      action: 'website',
    ),
  ];

  Future<void> _openContact(_ContactItem contact) async {
    final uri = Uri.tryParse(contact.value);
    if (uri == null) {
      _message('Informasi kontak belum valid.');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _message('Tidak dapat membuka ${contact.name}. Periksa aplikasi terkait.');
      }
    } catch (_) {
      if (mounted) _message('Kontak tidak dapat dibuka. Periksa koneksi atau aplikasi terkait.');
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildIntro()),
            SliverToBoxAdapter(child: _buildSectionTitle()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: _buildContactCard(_contacts[index]),
                  ),
                  childCount: _contacts.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHelpCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(31),
          bottomRight: Radius.circular(31),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .17),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 25),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY CAMPUS HUB',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Kontak Person',
                      style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.support_agent_rounded, color: Colors.white70, size: 27),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'Kami siap membantu.',
            style: TextStyle(color: Colors.white, fontSize: 26, height: 1.2, fontWeight: FontWeight.w900, letterSpacing: -.4),
          ),
          const SizedBox(height: 9),
          Text(
            'Temukan jalur bantuan yang tepat untuk pertanyaan akademik maupun kendala aplikasi.',
            style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 12.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8ECF6)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: _blue, size: 23),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Butuh bantuan?', style: TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 14)),
                  SizedBox(height: 5),
                  Text(
                    'Pilih kontak yang sesuai, lalu tekan kartu untuk menghubungi.',
                    style: TextStyle(color: _muted, fontSize: 11.5, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, 13),
      child: Text(
        'Daftar kontak',
        style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildContactCard(_ContactItem contact) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openContact(contact),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: const Color(0xFFE8ECF6)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: contact.color.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(contact.icon, color: contact.color, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name, style: const TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(contact.role, style: const TextStyle(color: _muted, fontSize: 11.5, height: 1.4)),
                    const SizedBox(height: 8),
                    Text(
                      contact.action == 'email' ? 'Buka aplikasi email' : 'Buka situs informasi',
                      style: TextStyle(color: contact.color, fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.arrow_outward_rounded, color: _blue, size: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF0FF), Color(0xFFF0EBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE5FF)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: _blue, size: 22),
            SizedBox(width: 11),
            Expanded(
              child: Text(
                'Catatan: kontak di halaman ini masih berupa contoh. Ganti nama, email, dan tautannya dengan kontak resmi kampus sebelum aplikasi dibagikan.',
                style: TextStyle(color: _ink, fontSize: 11.5, height: 1.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactItem {
  final String name;
  final String role;
  final IconData icon;
  final Color color;
  final String value;
  final String action;

  const _ContactItem({
    required this.name,
    required this.role,
    required this.icon,
    required this.color,
    required this.value,
    required this.action,
  });
}
