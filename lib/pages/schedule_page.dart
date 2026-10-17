import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const Color navy = Color(0xFF102B73);
  static const Color blue = Color(0xFF2563EB);
  static const Color violet = Color(0xFF6546F5);
  static const Color background = Color(0xFFF6F8FF);

  int selectedDay = _dayIndex(DateTime.now().weekday);
  final List<String> dayNames = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final List<String> dayFullNames = const [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  static int _dayIndex(int weekday) => weekday - 1;

  final List<_ClassItem> classes = const [
    _ClassItem(
      day: 0,
      start: '08:00',
      end: '09:40',
      title: 'Pemrograman Mobile',
      lecturer: 'Ibu Rina Puspita, S.Kom., M.Kom.',
      room: 'Lab Komputer 2',
      code: 'IF204',
      color: Color(0xFF4775F5),
      icon: Icons.code_rounded,
    ),
    _ClassItem(
      day: 0,
      start: '10:00',
      end: '11:40',
      title: 'Analisis dan Desain Sistem',
      lecturer: 'Bapak Andi Pratama, M.T.',
      room: 'Ruang C-203',
      code: 'IF212',
      color: Color(0xFF8B5CF6),
      icon: Icons.account_tree_rounded,
    ),
    _ClassItem(
      day: 1,
      start: '08:00',
      end: '09:40',
      title: 'Basis Data Lanjut',
      lecturer: 'Ibu Siti Rahma, M.Kom.',
      room: 'Lab Komputer 1',
      code: 'IF208',
      color: Color(0xFF0D9488),
      icon: Icons.storage_rounded,
    ),
    _ClassItem(
      day: 1,
      start: '13:00',
      end: '14:40',
      title: 'Rekayasa Perangkat Lunak',
      lecturer: 'Bapak Fajar Nugroho, M.Kom.',
      room: 'Ruang B-105',
      code: 'IF216',
      color: Color(0xFFF59E0B),
      icon: Icons.widgets_rounded,
    ),
    _ClassItem(
      day: 2,
      start: '09:00',
      end: '10:40',
      title: 'Komputasi Seluler',
      lecturer: 'Ibu Rina Puspita, S.Kom., M.Kom.',
      room: 'Lab Komputer 2',
      code: 'IF220',
      color: Color(0xFF4775F5),
      icon: Icons.phone_android_rounded,
    ),
    _ClassItem(
      day: 2,
      start: '13:00',
      end: '14:40',
      title: 'Interaksi Manusia dan Komputer',
      lecturer: 'Bapak Dimas Saputra, M.T.',
      room: 'Ruang A-301',
      code: 'IF218',
      color: Color(0xFFEC4899),
      icon: Icons.touch_app_rounded,
    ),
    _ClassItem(
      day: 3,
      start: '08:00',
      end: '09:40',
      title: 'Kecerdasan Buatan',
      lecturer: 'Bapak Arif Maulana, M.Kom.',
      room: 'Ruang C-201',
      code: 'IF224',
      color: Color(0xFF8B5CF6),
      icon: Icons.psychology_rounded,
    ),
    _ClassItem(
      day: 3,
      start: '10:00',
      end: '11:40',
      title: 'Keamanan Sistem Informasi',
      lecturer: 'Ibu Maya Lestari, M.Kom.',
      room: 'Ruang B-202',
      code: 'IF226',
      color: Color(0xFF0D9488),
      icon: Icons.shield_outlined,
    ),
    _ClassItem(
      day: 4,
      start: '08:00',
      end: '09:40',
      title: 'Etika Profesi Teknologi',
      lecturer: 'Bapak Yusuf Hidayat, M.Si.',
      room: 'Ruang A-202',
      code: 'MKU110',
      color: Color(0xFFF59E0B),
      icon: Icons.menu_book_rounded,
    ),
    _ClassItem(
      day: 4,
      start: '10:00',
      end: '11:40',
      title: 'Proyek Aplikasi',
      lecturer: 'Bapak Andi Pratama, M.T.',
      room: 'Studio Proyek',
      code: 'IF230',
      color: Color(0xFF4775F5),
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final todayClasses = classes.where((item) => item.day == selectedDay).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildWeekSelector()),
            SliverToBoxAdapter(child: _buildSummary(todayClasses.length)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 25, 22, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Agenda perkuliahan',
                        style: TextStyle(
                          color: navy,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EEFF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        '${todayClasses.length} kelas',
                        style: const TextStyle(color: blue, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (todayClasses.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildClassCard(todayClasses[index], index),
                    ),
                    childCount: todayClasses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 25),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 23),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MY CAMPUS HUB', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
                    SizedBox(height: 3),
                    Text('Jadwal Kuliah', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cari jadwal',
                onPressed: () => _showInfo('Fitur pencarian jadwal dapat dihubungkan ke data kampus.'),
                icon: const Icon(Icons.search_rounded, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Filter jadwal',
                onPressed: () => _showInfo('Filter jadwal bisa ditambahkan sesuai kebutuhan.'),
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 27),
          Text(
            '${months[now.month - 1]} ${now.year}',
            style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Atur waktumu, raih lebih banyak.',
            style: TextStyle(color: Colors.white, fontSize: 29, height: 1.15, fontWeight: FontWeight.w800, letterSpacing: -0.7),
          ),
          const SizedBox(height: 10),
          Text(
            'Semua kelas dalam satu tampilan yang rapi.',
            style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(color: const Color(0xFF203B85).withOpacity(0.06), blurRadius: 22, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: List.generate(7, (index) {
          final date = monday.add(Duration(days: index));
          final selected = selectedDay == index;
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedDay = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(colors: [blue, violet], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF8791AB),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: selected ? Colors.white : navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : (isToday ? blue : Colors.transparent),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummary(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: blue, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayFullNames[selectedDay], style: const TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  count == 0 ? 'Belum ada kelas terjadwal' : '$count kelas terjadwal hari ini',
                  style: const TextStyle(color: Color(0xFF6F7CA0), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF7A8BC0)),
        ],
      ),
    );
  }

  Widget _buildClassCard(_ClassItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFEBEFF9)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF203B85).withOpacity(0.045), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 57,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.start, style: const TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(item.end, style: const TextStyle(color: Color(0xFF98A1B8), fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(width: 3, height: 43, decoration: BoxDecoration(color: item.color.withOpacity(0.35), borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
          Container(width: 1, height: 105, color: const Color(0xFFEDF0F8)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item.code, style: TextStyle(color: item.color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                    ),
                    const Spacer(),
                    Icon(Icons.more_horiz_rounded, color: Colors.blueGrey.shade300),
                  ],
                ),
                const SizedBox(height: 11),
                Text(item.title, style: const TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800, height: 1.25)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: Colors.blueGrey.shade300),
                    const SizedBox(width: 5),
                    Expanded(child: Text(item.lecturer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7D87A1), fontSize: 10.5))),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.blueGrey.shade300),
                    const SizedBox(width: 5),
                    Expanded(child: Text(item.room, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7D87A1), fontSize: 10.5))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 3),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: item.color.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 4, 22, 30),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFE7EDFF), Color(0xFFF1EBFF)]),
            ),
            child: const Icon(Icons.event_available_rounded, color: blue, size: 34),
          ),
          const SizedBox(height: 17),
          const Text('Hari yang lebih santai', style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          const Text(
            'Tidak ada jadwal kuliah untuk hari ini. Gunakan waktumu untuk beristirahat atau menyelesaikan tugas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7D87A1), fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  void _showInfo(String message) {
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

class _ClassItem {
  final int day;
  final String start;
  final String end;
  final String title;
  final String lecturer;
  final String room;
  final String code;
  final Color color;
  final IconData icon;

  const _ClassItem({
    required this.day,
    required this.start,
    required this.end,
    required this.title,
    required this.lecturer,
    required this.room,
    required this.code,
    required this.color,
    required this.icon,
  });
}
