import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  static const Color _blue = Color(0xFF315CF5);
  static const Color _purple = Color(0xFF6546E8);
  static const Color _ink = Color(0xFF172B68);
  static const Color _muted = Color(0xFF7C88A8);
  static const Color _canvas = Color(0xFFF5F7FF);

  final TextEditingController _search = TextEditingController();
  String _category = 'Semua';

  // Contoh artikel statis. Ganti URL dengan tautan berita resmi kampus.
  final List<_CampusNews> _articles = const [
    _CampusNews(
      title: 'Persiapkan Perkuliahan dengan Lebih Teratur',
      summary:
          'Gunakan kalender akademik dan jadwal kuliah untuk membantu mengatur kegiatan belajar setiap pekan.',
      category: 'Akademik',
      date: 'Informasi mahasiswa',
      icon: Icons.school_rounded,
      color: Color(0xFF315CF5),
      url: 'https://www.kemdikbud.go.id/',
    ),
    _CampusNews(
      title: 'Manfaatkan Teknologi untuk Mendukung Belajar',
      summary:
          'Aplikasi digital dapat membantu mahasiswa mengakses materi, menyusun agenda, dan mengelola tugas.',
      category: 'Teknologi',
      date: 'Artikel edukasi',
      icon: Icons.devices_rounded,
      color: Color(0xFF6546E8),
      url: 'https://www.dikti.kemdikbud.go.id/',
    ),
    _CampusNews(
      title: 'Kembangkan Kompetensi di Luar Kelas',
      summary:
          'Kegiatan organisasi dan pengembangan diri bisa menjadi pelengkap pengalaman akademik mahasiswa.',
      category: 'Mahasiswa',
      date: 'Inspirasi kampus',
      icon: Icons.groups_rounded,
      color: Color(0xFF0D9488),
      url: 'https://www.kemdikbud.go.id/',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_CampusNews> get _filteredArticles {
    final query = _search.text.trim().toLowerCase();
    return _articles.where((article) {
      final categoryMatch = _category == 'Semua' || article.category == _category;
      final queryMatch = article.title.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query);
      return categoryMatch && queryMatch;
    }).toList();
  }

  Future<void> _openArticle(_CampusNews article) async {
    final uri = Uri.tryParse(article.url);
    if (uri == null) {
      _message('Tautan berita belum valid.');
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) _message('Tautan tidak dapat dibuka. Periksa koneksi internet.');
    } catch (_) {
      if (mounted) _message('Berita tidak dapat dibuka. Periksa koneksi internet.');
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
    final articles = _filteredArticles;
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildFilters()),
            SliverToBoxAdapter(child: _buildHeading(articles.length)),
            if (articles.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildArticleCard(articles[index]),
                    ),
                    childCount: articles.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 27),
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
                child: const Icon(Icons.newspaper_rounded, color: Colors.white, size: 25),
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
                      'Berita & Informasi',
                      style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.campaign_rounded, color: Colors.white70, size: 26),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'Tetap update, terus berkembang.',
            style: TextStyle(color: Colors.white, fontSize: 25, height: 1.2, fontWeight: FontWeight.w900, letterSpacing: -.4),
          ),
          const SizedBox(height: 9),
          Text(
            'Temukan informasi dan inspirasi untuk perjalanan akademikmu.',
            style: TextStyle(color: Colors.white.withValues(alpha: .83), fontSize: 12.5, height: 1.5),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: .18)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Wawasan kampus dalam satu tempat',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: _search,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Cari berita atau informasi...',
          hintStyle: const TextStyle(color: _muted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: _blue),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _search.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const categories = ['Semua', 'Akademik', 'Teknologi', 'Mahasiswa'];
    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 7),
        children: categories.map((category) {
          final selected = _category == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => setState(() => _category = category),
              showCheckmark: false,
              selectedColor: _blue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : _muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide(color: selected ? _blue : const Color(0xFFE6EAF6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeading(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 13),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Informasi pilihan',
              style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          Text('$count artikel', style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildArticleCard(_CampusNews article) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openArticle(article),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8ECF6)),
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
                      color: article.color.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(article.icon, color: article.color, size: 23),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      article.category,
                      style: TextStyle(color: article.color, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded, color: _muted, size: 18),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                article.title,
                style: const TextStyle(color: _ink, fontSize: 15, height: 1.35, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                article.summary,
                style: const TextStyle(color: _muted, fontSize: 12, height: 1.55),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF9AA4BC), size: 15),
                  const SizedBox(width: 6),
                  Expanded(child: Text(article.date, style: const TextStyle(color: _muted, fontSize: 10.5))),
                  const Text('Baca selengkapnya', style: TextStyle(color: _blue, fontSize: 10.5, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 54, color: _blue),
            SizedBox(height: 14),
            Text('Berita tidak ditemukan', style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w900)),
            SizedBox(height: 7),
            Text('Coba kata kunci atau kategori yang berbeda.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CampusNews {
  final String title;
  final String summary;
  final String category;
  final String date;
  final IconData icon;
  final Color color;
  final String url;

  const _CampusNews({
    required this.title,
    required this.summary,
    required this.category,
    required this.date,
    required this.icon,
    required this.color,
    required this.url,
  });
}
