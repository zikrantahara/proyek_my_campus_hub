import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color navy = Color(0xFF102B73);
  static const Color blue = Color(0xFF315CF5);
  static const Color violet = Color(0xFF6546F5);
  static const Color background = Color(0xFFF6F8FF);

  String selectedFilter = 'Semua';

  final List<_NoticeItem> notices = [
    _NoticeItem(
      title: 'Pengingat jadwal kuliah',
      message: 'Kelas Pemrograman Mobile dimulai pukul 08.00. Pastikan kamu datang tepat waktu.',
      category: 'Akademik',
      time: 'Hari ini · 07.00',
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF4775F5),
      unread: true,
    ),
    _NoticeItem(
      title: 'Tenggat pengumpulan tugas',
      message: 'Jangan lupa mengumpulkan tugas praktikum sebelum batas waktu berakhir.',
      category: 'Tugas',
      time: 'Hari ini · 06.30',
      icon: Icons.assignment_rounded,
      color: Color(0xFFEF8B2C),
      unread: true,
    ),
    _NoticeItem(
      title: 'Informasi akademik',
      message: 'Periksa kembali pengumuman dari program studi untuk mendapatkan informasi terbaru.',
      category: 'Pengumuman',
      time: 'Kemarin · 15.20',
      icon: Icons.campaign_rounded,
      color: Color(0xFF8B5CF6),
      unread: false,
    ),
    _NoticeItem(
      title: 'Jadwal diperbarui',
      message: 'Pastikan jadwal kuliah yang kamu gunakan sudah sesuai dengan informasi terbaru.',
      category: 'Akademik',
      time: 'Kemarin · 10.15',
      icon: Icons.update_rounded,
      color: Color(0xFF0D9488),
      unread: false,
    ),
    _NoticeItem(
      title: 'Selamat datang di My Campus Hub',
      message: 'Gunakan aplikasi ini untuk membantu mengakses layanan dan informasi perkuliahan.',
      category: 'Sistem',
      time: '17 Okt · 08.00',
      icon: Icons.waving_hand_rounded,
      color: Color(0xFFEC4899),
      unread: false,
    ),
  ];

  List<_NoticeItem> get filteredNotices {
    if (selectedFilter == 'Belum dibaca') {
      return notices.where((notice) => notice.unread).toList();
    }
    if (selectedFilter == 'Akademik') {
      return notices.where((notice) => notice.category == 'Akademik').toList();
    }
    return notices;
  }

  int get unreadCount => notices.where((notice) => notice.unread).length;

  @override
  Widget build(BuildContext context) {
    final visibleNotices = filteredNotices;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildOverview()),
            SliverToBoxAdapter(child: _buildFilters()),
            SliverToBoxAdapter(child: _buildListHeading()),
            if (visibleNotices.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildNoticeCard(visibleNotices[index]),
                    ),
                    childCount: visibleNotices.length,
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
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1746C7), Color(0xFF5146E5), Color(0xFF7957EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 23),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MY CAMPUS HUB', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                    SizedBox(height: 3),
                    Text('Notifikasi', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tandai semua dibaca',
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Opsi notifikasi',
                onPressed: () => _showMessage('Pengaturan notifikasi dapat ditambahkan pada tahap berikutnya.'),
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'Tetap terhubung.',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'Informasi penting kampus, langsung dalam genggaman.',
            style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12.5, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: const Color(0xFF203B85).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 7)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [blue, violet]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$unreadCount notifikasi belum dibaca', style: const TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                const Text('Kamu sudah mendapatkan informasi terbaru.', style: TextStyle(color: Color(0xFF8791AB), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFFEDF1FF), borderRadius: BorderRadius.circular(10)),
            child: Text('$unreadCount baru', style: const TextStyle(color: blue, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['Semua', 'Belum dibaca', 'Akademik'];

    return SizedBox(
      height: 65,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 17, 20, 8),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => setState(() => selectedFilter = filter),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF77829D),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: blue,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? blue : const Color(0xFFE9EDF7)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          );
        },
      ),
    );
  }

  Widget _buildListHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 13),
      child: Row(
        children: [
          const Expanded(
            child: Text('Aktivitas terbaru', style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
          ),
          Text('${filteredNotices.length} item', style: const TextStyle(color: Color(0xFF8A94AE), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(_NoticeItem notice) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () => _openNotice(notice),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: notice.unread ? const Color(0xFFDCE5FF) : const Color(0xFFEBEFF9),
            ),
            boxShadow: [
              BoxShadow(color: const Color(0xFF203B85).withOpacity(0.035), blurRadius: 14, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: notice.color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(notice.icon, color: notice.color, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notice.title,
                            style: TextStyle(
                              color: navy,
                              fontSize: 13,
                              fontWeight: notice.unread ? FontWeight.w800 : FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (notice.unread) ...[
                          const SizedBox(width: 7),
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(color: blue, shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notice.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF7D87A1), fontSize: 11.2, height: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: Colors.blueGrey.shade300),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(notice.time, style: const TextStyle(color: Color(0xFF9AA4BC), fontSize: 10)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: notice.color.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(notice.category, style: TextStyle(color: notice.color, fontSize: 9.5, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFE8EDFF), Color(0xFFF0EAFF)]),
            ),
            child: const Icon(Icons.notifications_off_outlined, color: blue, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Tidak ada notifikasi', style: TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          const Text(
            'Belum ada notifikasi untuk kategori ini. Coba pilih filter yang lain.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7D87A1), fontSize: 11.5, height: 1.55),
          ),
        ],
      ),
    );
  }

  void _openNotice(_NoticeItem notice) {
    setState(() => notice.unread = false);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE2EF), borderRadius: BorderRadius.circular(5))),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(color: notice.color.withOpacity(0.11), borderRadius: BorderRadius.circular(15)),
                    child: Icon(notice.icon, color: notice.color, size: 23),
                  ),
                  const SizedBox(width: 13),
                  Expanded(child: Text(notice.title, style: const TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w800))),
                ],
              ),
              const SizedBox(height: 17),
              Text(notice.message, style: const TextStyle(color: Color(0xFF68748F), fontSize: 13, height: 1.65)),
              const SizedBox(height: 17),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF8A94AE)),
                  const SizedBox(width: 6),
                  Text(notice.time, style: const TextStyle(color: Color(0xFF8A94AE), fontSize: 11)),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final notice in notices) {
        notice.unread = false;
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Semua notifikasi ditandai sudah dibaca.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
  }
}

class _NoticeItem {
  final String title;
  final String message;
  final String category;
  final String time;
  final IconData icon;
  final Color color;
  bool unread;

  _NoticeItem({
    required this.title,
    required this.message,
    required this.category,
    required this.time,
    required this.icon,
    required this.color,
    required this.unread,
  });
}
