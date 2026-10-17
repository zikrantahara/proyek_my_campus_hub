import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  static const blue = Color(0xFF315CF5);
  static const purple = Color(0xFF6546E8);
  static const ink = Color(0xFF172B68);
  static const muted = Color(0xFF7C88A8);
  static const canvas = Color(0xFFF5F7FF);

  final search = TextEditingController();
  String filter = 'Semua';

  final videos = const <CampusVideo>[
    CampusVideo(
      title: 'Tutorial Firebase',
      description: 'Pelajari dasar menghubungkan aplikasi Flutter dengan Firebase.',
      category: 'Pengembangan',
      youtubeId: '58IUNjXSwp8',
      color: Color(0xFF315CF5),
      icon: Icons.cloud_rounded,
    ),
    CampusVideo(
      title: 'Cara Build APK',
      description: 'Panduan menyiapkan aplikasi Flutter menjadi file APK untuk Android.',
      category: 'Pengembangan',
      youtubeId: 'Uy-1cGUW0Mc',
      color: Color(0xFF6546E8),
      icon: Icons.phone_android_rounded,
    ),
  ];

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  List<CampusVideo> get filtered => videos.where((v) {
        final q = search.text.trim().toLowerCase();
        return (filter == 'Semua' || v.category == filter) &&
            (v.title.toLowerCase().contains(q) ||
                v.description.toLowerCase().contains(q));
      }).toList();

  Future<void> openVideo(CampusVideo video) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=${video.youtubeId}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) showMessage('Video tidak dapat dibuka. Periksa koneksi internet.');
    } catch (_) {
      if (mounted) showMessage('Video gagal dibuka. Periksa package url_launcher.');
    }
  }

  void showMessage(String message) {
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
    final list = filtered;
    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: header()),
            SliverToBoxAdapter(child: searchBox()),
            SliverToBoxAdapter(child: filters()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
                child: Row(children: [
                  const Expanded(child: Text('Rekomendasi video', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900))),
                  Text('${list.length} video', style: const TextStyle(color: muted, fontSize: 11)),
                ]),
              ),
            ),
            if (list.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Video tidak ditemukan', style: TextStyle(color: ink, fontWeight: FontWeight.w800))),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: videoCard(list[index]),
                    ),
                    childCount: list.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget header() => Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 27),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [blue, purple], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(31), bottomRight: Radius.circular(31)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .17), borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 27),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MY CAMPUS HUB', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('Video & Tutorial', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
            ])),
            const Icon(Icons.ondemand_video_rounded, color: Colors.white70, size: 26),
          ]),
          const SizedBox(height: 25),
          const Text('Belajar dengan cara yang lebih seru.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.2, fontWeight: FontWeight.w900, letterSpacing: -.4)),
          const SizedBox(height: 9),
          Text('Temukan panduan dan materi video untuk mendukung aktivitas kuliahmu.', style: TextStyle(color: Colors.white.withValues(alpha: .83), fontSize: 12.5, height: 1.5)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: .18))),
            child: Row(children: [
              const Icon(Icons.video_library_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 9),
              Expanded(child: Text('${videos.length} video tersedia', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ]),
          ),
        ]),
      );

  Widget searchBox() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari video atau tutorial...',
            hintStyle: const TextStyle(color: muted, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: blue),
            suffixIcon: search.text.isEmpty ? null : IconButton(onPressed: () { search.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          ),
        ),
      );

  Widget filters() => SizedBox(
        height: 62,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 7),
          children: ['Semua', 'Pengembangan'].map((item) {
            final selected = filter == item;
            return Padding(
              padding: const EdgeInsets.only(right: 9),
              child: ChoiceChip(
                label: Text(item),
                selected: selected,
                onSelected: (_) => setState(() => filter = item),
                showCheckmark: false,
                labelStyle: TextStyle(color: selected ? Colors.white : muted, fontSize: 11.5, fontWeight: FontWeight.w800),
                selectedColor: blue,
                backgroundColor: Colors.white,
                side: BorderSide(color: selected ? blue : const Color(0xFFE6EAF6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            );
          }).toList(),
        ),
      );

  Widget videoCard(CampusVideo video) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openVideo(video),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(23), border: Border.all(color: const Color(0xFFE8ECF6))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(
                aspectRatio: 16 / 8.5,
                child: Stack(fit: StackFit.expand, children: [
                  Image.network(
                    'https://img.youtube.com/vi/${video.youtubeId}/hqdefault.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => thumbnailFallback(video),
                  ),
                  DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .45)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                  Center(child: Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .95), shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, size: 38, color: blue),
                  )),
                  Positioned(
                    left: 13, top: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: video.color, borderRadius: BorderRadius.circular(9)),
                      child: Text(video.category, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(video.title, style: const TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  Text(video.description, style: const TextStyle(color: muted, fontSize: 11.5, height: 1.5)),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Icon(Icons.play_circle_outline_rounded, color: blue, size: 18),
                    const SizedBox(width: 7),
                    const Expanded(child: Text('Tonton di YouTube', style: TextStyle(color: blue, fontSize: 11, fontWeight: FontWeight.w800))),
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: const Color(0xFFEDF1FF), borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.arrow_outward_rounded, color: blue, size: 17),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      );

  Widget thumbnailFallback(CampusVideo video) => Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [video.color, purple], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(child: Icon(video.icon, color: Colors.white.withValues(alpha: .85), size: 58)),
      );
}

class CampusVideo {
  final String title;
  final String description;
  final String category;
  final String youtubeId;
  final Color color;
  final IconData icon;

  const CampusVideo({
    required this.title,
    required this.description,
    required this.category,
    required this.youtubeId,
    required this.color,
    required this.icon,
  });
}
