import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final nimController = TextEditingController();

  bool isRegister = false;
  bool obscurePassword = true;
  bool loading = false;

  static const Color navy = Color(0xFF102B73);
  static const Color blue = Color(0xFF2563EB);
  static const Color violet = Color(0xFF6546F5);
  static const Color background = Color(0xFFF6F8FF);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    nimController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Email dan password wajib diisi.', error: true);
      return;
    }

    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      showMessage(authError(e.code), error: true);
    } catch (e) {
      showMessage('Terjadi kesalahan: $e', error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    if (nameController.text.trim().isEmpty ||
        nimController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Semua data pendaftaran wajib diisi.', error: true);
      return;
    }

    if (passwordController.text.length < 6) {
      showMessage('Password minimal 6 karakter.', error: true);
      return;
    }

    setState(() => loading = true);
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final newUser = credential.user;
      if (newUser != null) {
        await newUser.updateDisplayName(nameController.text.trim());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set({
          'uid': newUser.uid,
          'name': nameController.text.trim(),
          'nama': nameController.text.trim(),
          'nim': nimController.text.trim(),
          'email': emailController.text.trim(),
          'phone': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      showMessage(authError(e.code), error: true);
    } catch (e) {
      showMessage('Pendaftaran gagal: $e', error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'network-request-failed':
        return 'Periksa koneksi internet kamu.';
      default:
        return 'Terjadi kesalahan autentikasi.';
    }
  }

  void showMessage(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                error ? Icons.error_outline_rounded : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
          backgroundColor: error ? const Color(0xFFB42318) : const Color(0xFF176B4D),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
  }

  InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF6676A5)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F7FE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFE7EBF7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Container(
            height: 310,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1746C7), Color(0xFF5146E5), Color(0xFF8A5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(42),
                bottomRight: Radius.circular(42),
              ),
            ),
          ),
          Positioned(
            top: -55,
            right: -35,
            child: _GlowCircle(size: 190, color: Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            top: 100,
            left: -70,
            child: _GlowCircle(size: 180, color: Colors.white.withOpacity(0.07)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.17),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: const Icon(Icons.school_rounded, color: Colors.white, size: 25),
                              ),
                              const SizedBox(width: 11),
                              const Expanded(
                                child: Text(
                                  'MY CAMPUS HUB',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  'STUDENT APP',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),
                          const Text(
                            'Your Campus, One Hub.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1.08,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isRegister
                                ? 'Buat akun mahasiswa dan mulai perjalanan kampusmu.'
                                : 'Semua kebutuhan akademikmu, dalam satu tempat.',
                            style: TextStyle(color: Colors.white.withOpacity(0.86), fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF253B83).withOpacity(0.12),
                                  blurRadius: 32,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isRegister ? 'Buat akun baru' : 'Selamat datang 👋',
                                  style: const TextStyle(color: navy, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  isRegister ? 'Isi data berikut untuk mendaftar.' : 'Masuk untuk melanjutkan ke akunmu.',
                                  style: const TextStyle(color: Color(0xFF7B849E), fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                if (isRegister) ...[
                                  TextField(
                                    controller: nameController,
                                    textCapitalization: TextCapitalization.words,
                                    decoration: fieldDecoration(label: 'Nama lengkap', icon: Icons.person_outline_rounded),
                                  ),
                                  const SizedBox(height: 13),
                                  TextField(
                                    controller: nimController,
                                    keyboardType: TextInputType.number,
                                    decoration: fieldDecoration(label: 'NIM', icon: Icons.badge_outlined),
                                  ),
                                  const SizedBox(height: 13),
                                ],
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: fieldDecoration(label: 'Email mahasiswa', icon: Icons.mail_outline_rounded),
                                ),
                                const SizedBox(height: 13),
                                TextField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  autofillHints: isRegister
                                      ? const [AutofillHints.newPassword]
                                      : const [AutofillHints.password],
                                  decoration: fieldDecoration(
                                    label: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    suffix: IconButton(
                                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                      icon: Icon(
                                        obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: const Color(0xFF7B849E),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isRegister) ...[
                                  const SizedBox(height: 9),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: loading ? null : _forgotPassword,
                                      child: const Text('Lupa password?'),
                                    ),
                                  ),
                                ] else
                                  const SizedBox(height: 22),
                                SizedBox(
                                  height: 54,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [blue, violet],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: blue.withOpacity(0.23),
                                          blurRadius: 16,
                                          offset: const Offset(0, 7),
                                        ),
                                      ],
                                    ),
                                    child: FilledButton(
                                      onPressed: loading ? null : (isRegister ? register : login),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledBackgroundColor: const Color(0xFF9CA9D4),
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                                      ),
                                      child: loading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  isRegister ? 'BUAT AKUN' : 'MASUK SEKARANG',
                                                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
                                                ),
                                                const SizedBox(width: 9),
                                                const Icon(Icons.arrow_forward_rounded, size: 19),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 19),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        isRegister ? 'Sudah punya akun?' : 'Belum punya akun?',
                                        style: const TextStyle(color: Color(0xFF7B849E), fontSize: 13),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: loading
                                          ? null
                                          : () => setState(() => isRegister = !isRegister),
                                      child: Text(
                                        isRegister ? 'Masuk' : 'Daftar sekarang',
                                        style: const TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_user_outlined, size: 15, color: Color(0xFF9AA4BE)),
                              SizedBox(width: 7),
                              Text(
                                'Akses aman untuk komunitas kampus',
                                style: TextStyle(color: Color(0xFF8791AB), fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showMessage('Masukkan email terlebih dahulu.', error: true);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showMessage('Link reset password dikirim ke email kamu.');
    } on FirebaseAuthException catch (e) {
      showMessage(authError(e.code), error: true);
    } catch (e) {
      showMessage('Gagal mengirim link reset: $e', error: true);
    }
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
