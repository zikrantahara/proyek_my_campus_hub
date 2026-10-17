import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primary = Color(0xFF315CF5);
  static const Color _purple = Color(0xFF6547E8);
  static const Color _ink = Color(0xFF172B68);
  static const Color _muted = Color(0xFF7C88A8);
  static const Color _canvas = Color(0xFFF5F7FF);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _programController = TextEditingController();
  final _picker = ImagePicker();

  User? get _user => FirebaseAuth.instance.currentUser;

  bool _loading = true;
  bool _saving = false;
  XFile? _pickedPhoto;
  String? _photoUrl;
  String? _createdAtLabel;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _programController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFB42318) : _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    _emailController.text = user.email ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? <String, dynamic>{};
      _nameController.text =
          (data['name'] as String?) ?? user.displayName ?? '';
      _nimController.text = (data['nim'] as String?) ?? '';
      _phoneController.text = (data['phone'] as String?) ?? '';
      _programController.text = (data['program'] as String?) ?? '';
      _photoUrl = (data['photoUrl'] as String?) ?? user.photoURL;

      final createdAt = data['updatedAt'];
      if (createdAt is Timestamp) {
        final date = createdAt.toDate();
        _createdAtLabel =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      _showMessage('Profil belum dapat dimuat. Periksa koneksi Firebase.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ganti foto profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8EDFF),
                  child: Icon(Icons.photo_library_rounded, color: _primary),
                ),
                title: const Text('Pilih dari galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8EDFF),
                  child: Icon(Icons.camera_alt_rounded, color: _primary),
                ),
                title: const Text('Ambil foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final result = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (result != null && mounted) {
        setState(() => _pickedPhoto = result);
        _showMessage(
          'Foto dipilih. Untuk menyimpan foto ke cloud, Firebase Storage perlu dikonfigurasi.',
        );
      }
    } catch (e) {
      _showMessage('Foto tidak dapat dipilih: $e', error: true);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _user;
    if (user == null) {
      _showMessage('Sesi login tidak ditemukan. Silakan login kembali.', error: true);
      return;
    }

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'nim': _nimController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'program': _programController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (_nameController.text.trim().isNotEmpty &&
          _nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(_nameController.text.trim());
      }

      if (!mounted) return;
      setState(() {
        _pickedPhoto = null;
        _createdAtLabel = 'Baru saja';
      });
      _showMessage('Profil berhasil disimpan.');
    } catch (e) {
      _showMessage('Gagal menyimpan profil: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return 'MH';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
  }

  Widget _avatar({double size = 104}) {
    Widget child;
    if (_pickedPhoto != null) {
      child = Image.file(
        File(_pickedPhoto!.path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(size),
      );
    } else if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      child = Image.network(
        _photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(size),
      );
    } else {
      child = _avatarFallback(size);
    }

    return ClipOval(
      child: SizedBox(width: size, height: size, child: child),
    );
  }

  Widget _avatarFallback(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .30,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        validator: validator,
        style: const TextStyle(
          color: _ink,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: _muted),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF0F2F8) : _canvas,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8ECF6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD92D20)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: _canvas,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _primary),
            )
          : user == null
              ? _buildSignedOut()
              : _buildProfile(user),
    );
  }

  Widget _buildSignedOut() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDFF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.person_off_rounded, size: 42, color: _primary),
              ),
              const SizedBox(height: 18),
              const Text(
                'Kamu belum login',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login terlebih dahulu untuk melihat dan mengatur profil mahasiswa.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(User user) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              22,
              MediaQuery.of(context).padding.top + 18,
              22,
              32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white),
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
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Profil Mahasiswa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Muat ulang profil',
                      onPressed: () {
                        setState(() => _loading = true);
                        _loadProfile();
                      },
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white70, width: 2),
                            ),
                            child: _avatar(size: 104),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _choosePhoto,
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.camera_alt_rounded, size: 19, color: _primary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _nameController.text.trim().isEmpty
                            ? 'Nama Mahasiswa'
                            : _nameController.text.trim(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _nimController.text.trim().isEmpty
                            ? (user.email ?? 'Lengkapi data mahasiswa')
                            : 'NIM ${_nimController.text.trim()}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user_rounded, size: 15, color: Colors.white),
                            SizedBox(width: 7),
                            Text(
                              'Akun mahasiswa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(
                    'Informasi pribadi',
                    'Pastikan data kamu sudah benar.',
                    Icons.badge_rounded,
                  ),
                  _field(
                    controller: _nameController,
                    label: 'Nama lengkap',
                    hint: 'Masukkan nama lengkap',
                    icon: Icons.person_outline_rounded,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nama lengkap wajib diisi'
                        : null,
                  ),
                  _field(
                    controller: _nimController,
                    label: 'NIM',
                    hint: 'Masukkan nomor induk mahasiswa',
                    icon: Icons.school_outlined,
                  ),
                  _field(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'nama@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  _field(
                    controller: _phoneController,
                    label: 'Nomor telepon',
                    hint: '08xxxxxxxxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _field(
                    controller: _programController,
                    label: 'Program studi',
                    hint: 'Contoh: Informatika',
                    icon: Icons.menu_book_rounded,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8ECF6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDFF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.cloud_done_rounded, color: _primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sinkronisasi data',
                                style: TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Data profil disimpan ke Firebase Firestore.',
                                style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A36A)),
                      ],
                    ),
                  ),
                  if (_createdAtLabel != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Pembaruan terakhir: $_createdAtLabel',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        elevation: 0,
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
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _saving ? 'Menyimpan...' : 'Simpan perubahan',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'My Campus Hub • Your Campus, One Hub',
                      style: TextStyle(
                        color: Color(0xFFA1AAC0),
                        fontSize: 11,
                        letterSpacing: .3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
