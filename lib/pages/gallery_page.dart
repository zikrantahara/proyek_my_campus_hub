import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const Color _blue = Color(0xFF315CF5);
  static const Color _purple = Color(0xFF6246EA);
  static const Color _ink = Color(0xFF14275B);
  static const Color _muted = Color(0xFF7180A4);
  static const Color _page = Color(0xFFF5F7FF);

  final List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _filter = 'Semua';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    if (mounted) setState(() => _loading = true);

    // Foto pada versi ini disimpan di penyimpanan lokal perangkat.
    // Browser tidak dapat membaca file lokal aplikasi Android.
    if (kIsWeb) {
      if (!mounted) return;
      setState(() {
        _items.clear();
        _loading = false;
      });
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final index = File('${directory.path}/gallery_index.json');

      if (!await index.exists()) {
        if (!mounted) return;
        setState(() {
          _items.clear();
          _loading = false;
        });
        return;
      }

      final content = await index.readAsString();
      final decoded = content.trim().isEmpty ? <dynamic>[] : jsonDecode(content) as List;
      final data = decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Galeri belum dapat dibaca: $e');
    }
  }

  String _normalType(Map<String, dynamic> item) {
    final raw = (item['type'] ?? '').toString().toLowerCase().trim();
    if (raw.contains('ktp')) return 'KTP';
    if (raw.contains('ktm')) return 'KTM';
    if (raw.contains('foto')) return 'Foto';
    return raw.isEmpty ? 'File' : raw[0].toUpperCase() + raw.substring(1);
  }

  List<Map<String, dynamic>> get _filteredItems {
    return _items.where((item) {
      final type = _normalType(item);
      final matchesFilter = _filter == 'Semua' || type == _filter;
      final name = (item['name'] ?? item['fileName'] ?? '').toString();
      final matchesQuery = name.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _openImage(Map<String, dynamic> item) {
    final path = (item['path'] ?? '').toString();
    final name = (item['name'] ?? item['fileName'] ?? 'Gambar').toString();

    if (kIsWeb) {
      _message(
        'Pratinjau file lokal tersedia di aplikasi Android. '
        'Di Chrome, Image.file tidak didukung.',
      );
      return;
    }

    if (path.isEmpty || !File(path).existsSync()) {
      _message('File gambar tidak ditemukan di perangkat.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _GalleryImageViewer(path: path, title: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _filteredItems;

    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadGallery,
          color: _blue,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildSearch(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildFilters(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Koleksi tersimpan',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7ECFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${visibleItems.length} file',
                          style: const TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: _blue),
                  ),
                )
              else if (visibleItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildGalleryCard(visibleItems[index]),
                      childCount: visibleItems.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                  size: 24,
                ),
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
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Galeri Saya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang galeri',
                onPressed: _loadGallery,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 23),
          const Text(
            'Semua momen dalam satu tempat.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Foto dan dokumen yang kamu simpan akan tampil di sini.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_copy_outlined,
                    color: Colors.white, size: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_items.length} file tersimpan di perangkat ini',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF263D83).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _query = value.trim()),
        decoration: InputDecoration(
          hintText: 'Cari nama file...',
          hintStyle: const TextStyle(color: _muted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: _blue),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['Semua', 'Foto', 'KTP', 'KTM'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => setState(() => _filter = filter),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: selected ? Colors.white : _muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              backgroundColor: Colors.white,
              selectedColor: _blue,
              side: BorderSide(
                color: selected ? _blue : const Color(0xFFE8ECF8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGalleryCard(Map<String, dynamic> item) {
    final path = (item['path'] ?? '').toString();
    final name = (item['name'] ?? item['fileName'] ?? 'File tanpa nama').toString();
    final type = _normalType(item);
    final isDocument = type == 'KTP' || type == 'KTM';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openImage(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFE9EEFF),
                    child: kIsWeb
                        ? _imageFallback(isDocument)
                        : (path.isNotEmpty && File(path).existsSync()
                            ? Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imageFallback(isDocument),
                              )
                            : _imageFallback(isDocument)),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.open_in_full_rounded,
                        size: 16,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: Color(0xFF2FA77A),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Tersimpan lokal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _muted.withValues(alpha: 0.95),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(bool isDocument) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isDocument
                  ? Icons.description_rounded
                  : Icons.image_rounded,
              color: _blue,
              size: 29,
            ),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Pratinjau di APK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 10, 34, 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE7ECFF), Color(0xFFF0E9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: _blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Galeri masih kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filter == 'Semua'
                  ? 'Foto atau dokumen yang kamu simpan akan muncul di sini.'
                  : 'Belum ada file kategori $_filter. Coba kategori lain atau unggah file terlebih dahulu.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _filter = 'Semua';
                  _query = '';
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tampilkan semua file'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: Color(0xFFD9E1FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryImageViewer extends StatelessWidget {
  final String path;
  final String title;

  const _GalleryImageViewer({
    required this.path,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1328),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1328),
        foregroundColor: Colors.white,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 4,
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Gambar tidak dapat dibuka.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
