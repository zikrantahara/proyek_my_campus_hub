import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class UploadPage extends StatefulWidget {
  final String type;
  final String title;

  const UploadPage({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  static const Color _blue = Color(0xFF315CF5);
  static const Color _purple = Color(0xFF6546E8);
  static const Color _ink = Color(0xFF172B68);
  static const Color _muted = Color(0xFF7C88A8);
  static const Color _canvas = Color(0xFFF5F7FF);

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _saving = false;
  String? _savedId;

  bool get _isPhoto => widget.type.toLowerCase() == 'foto';

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFB42318) : _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final result = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (result != null && mounted) {
        setState(() {
          _selectedImage = result;
          _savedId = null;
        });
      }
    } catch (e) {
      _message('Tidak dapat memilih gambar: $e', error: true);
    }
  }

  Future<void> _save() async {
    if (_selectedImage == null) {
      _message('Pilih gambar terlebih dahulu.', error: true);
      return;
    }

    if (kIsWeb) {
      _message(
        'Penyimpanan gambar lokal ini ditujukan untuk APK Android. '
        'Untuk Chrome atau sinkronisasi cloud, perlu Firebase Storage.',
        error: true,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('Silakan login terlebih dahulu.', error: true);
      return;
    }

    setState(() => _saving = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final extension = _selectedImage!.name.contains('.')
          ? _selectedImage!.name.split('.').last.toLowerCase()
          : 'jpg';
      final id =
          '${widget.type.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}';
      final destination = File('${directory.path}/$id.$extension');

      await File(_selectedImage!.path).copy(destination.path);

      final indexFile = File('${directory.path}/gallery_index.json');
      List<dynamic> entries = [];
      if (await indexFile.exists()) {
        final raw = await indexFile.readAsString();
        if (raw.trim().isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is List) entries = decoded;
        }
      }

      entries.insert(0, {
        'id': id,
        'type': widget.type,
        'name': _selectedImage!.name,
        'path': destination.path,
      });
      await indexFile.writeAsString(jsonEncode(entries));

      // Simpan metadata di Firestore; file gambar tetap berada di perangkat.
      await FirebaseFirestore.instance.collection('uploads').doc(id).set({
        'fileId': id,
        'userId': user.uid,
        'type': widget.type,
        'fileName': _selectedImage!.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _savedId = id;
        _selectedImage = null;
      });
      _message('Berhasil disimpan. File sekarang tercatat di galeri aplikasi.');
    } catch (e) {
      _message(
        'Gagal menyimpan. Periksa izin perangkat dan konfigurasi Firebase.\n$e',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        foregroundColor: _ink,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
          children: [
            _buildHero(),
            const SizedBox(height: 20),
            _buildPreview(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri HP',
                    onTap: () => _pick(ImageSource.gallery),
                  ),
                ),
                if (_isPhoto) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      onTap: () => _pick(ImageSource.camera),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 55,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  _saving ? 'Menyimpan...' : 'Simpan file',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (_savedId != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC7EBD6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF16834A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'File berhasil disimpan',
                            style: TextStyle(
                              color: Color(0xFF17663D),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $_savedId',
                            style: const TextStyle(
                              color: Color(0xFF357653),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isPhoto ? Icons.add_a_photo_rounded : Icons.upload_file_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Simpan ${widget.title.toLowerCase()} dengan mudah.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih gambar, periksa pratinjau, lalu simpan ke koleksi aplikasi.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .83),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 270,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EAF6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF263D83).withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _selectedImage == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDFF),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Icon(
                      Icons.image_search_rounded,
                      color: _blue,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum ada gambar dipilih',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih dari galeri atau gunakan kamera.',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            )
          : kIsWeb
              ? const Center(
                  child: Text(
                    'Pratinjau gambar tersedia di APK Android.',
                    style: TextStyle(color: _muted),
                  ),
                )
              : Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: _muted, size: 42),
                  ),
                ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: _saving ? null : onTap,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _blue,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFDCE4FF)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE5FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _blue, size: 22),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'File gambar disimpan di penyimpanan lokal APK, sedangkan ID dan metadata dicatat di Firestore. Agar gambar bisa dibuka dari perangkat lain atau tampil di web, integrasikan Firebase Storage.',
              style: TextStyle(
                color: _ink,
                fontSize: 11.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
