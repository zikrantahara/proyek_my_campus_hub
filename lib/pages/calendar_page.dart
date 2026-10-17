import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const Color navy = Color(0xFF102B73);
  static const Color blue = Color(0xFF315CF5);
  static const Color violet = Color(0xFF6546F5);
  static const Color background = Color(0xFFF6F8FF);

  late DateTime displayedMonth;
  late DateTime selectedDate;

  final Map<String, List<_CalendarEvent>> events = {
    _dateKey(DateTime(2026, 10, 5)): const [
      _CalendarEvent('Kuliah Pemrograman Mobile', '08:00 – 09:40', 'Ruang Lab 2', Color(0xFF4775F5), Icons.laptop_mac_rounded),
      _CalendarEvent('Kumpul tugas praktikum', '13:00 – 14:00', 'Tugas akademik', Color(0xFF8B5CF6), Icons.assignment_rounded),
    ],
    _dateKey(DateTime(2026, 10, 12)): const [
      _CalendarEvent('Kuliah Analisis Sistem', '09:00 – 10:40', 'Ruang C-203', Color(0xFF0D9488), Icons.menu_book_rounded),
    ],
    _dateKey(DateTime(2026, 10, 17)): const [
      _CalendarEvent('Review materi kuliah', '10:00 – 11:00', 'Belajar mandiri', Color(0xFF8B5CF6), Icons.auto_stories_rounded),
    ],
    _dateKey(DateTime(2026, 10, 20)): const [
      _CalendarEvent('Batas pengumpulan tugas', '23:59', 'Pemrograman Mobile', Color(0xFFEF4444), Icons.flag_rounded),
    ],
    _dateKey(DateTime(2026, 10, 23)): const [
      _CalendarEvent('Kuis Basis Data', '08:00 – 09:00', 'Ruang B-105', Color(0xFFF59E0B), Icons.quiz_rounded),
      _CalendarEvent('Diskusi kelompok', '13:30 – 14:30', 'Perpustakaan', Color(0xFF4775F5), Icons.groups_rounded),
    ],
    _dateKey(DateTime(2026, 10, 28)): const [
      _CalendarEvent('Presentasi proyek', '10:00 – 12:00', 'Studio Proyek', Color(0xFF0D9488), Icons.co_present_rounded),
    ],
  };

  static String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    displayedMonth = DateTime(now.year, now.month);
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  List<_CalendarEvent> get selectedEvents =>
      events[_dateKey(selectedDate)] ?? const <_CalendarEvent>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildMonthCard()),
            SliverToBoxAdapter(child: _buildLegend()),
            SliverToBoxAdapter(child: _buildAgendaHeader()),
            if (selectedEvents.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildEventCard(selectedEvents[index]),
                    ),
                    childCount: selectedEvents.length,
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
                child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 23),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MY CAMPUS HUB', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                    SizedBox(height: 3),
                    Text('Kalender Akademik', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hari ini',
                onPressed: _goToToday,
                icon: const Icon(Icons.today_rounded, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Informasi kalender',
                onPressed: () => _showMessage('Pilih tanggal untuk melihat agenda akademik.'),
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text('Rencanakan hari-harimu', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          const SizedBox(height: 8),
          Text(
            'Lihat agenda kuliah dan tenggat tugas dalam satu kalender.',
            style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12.5, height: 1.45),
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              _headerStat(Icons.event_available_rounded, '${_monthEventCount()} agenda', 'Bulan ini'),
              const SizedBox(width: 10),
              _headerStat(Icons.check_circle_outline_rounded, '${selectedEvents.length} agenda', 'Tanggal dipilih'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.13)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(label, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard() {
    final monthName = _monthName(displayedMonth.month);
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: const Color(0xFF203B85).withOpacity(0.055), blurRadius: 22, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.date_range_rounded, color: blue, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(monthName, style: const TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('${displayedMonth.year}', style: const TextStyle(color: Color(0xFF8A94AE), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _monthButton(Icons.chevron_left_rounded, () {
                setState(() => displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1));
              }),
              const SizedBox(width: 7),
              _monthButton(Icons.chevron_right_rounded, () {
                setState(() => displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1));
              }),
            ],
          ),
          const SizedBox(height: 21),
          Row(
            children: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(day, style: TextStyle(color: Color(0xFF98A1B8), fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 11),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 3,
              childAspectRatio: 0.76,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingBlanks + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
              final isSelected = _sameDate(date, selectedDate);
              final isToday = _sameDate(date, DateTime(today.year, today.month, today.day));
              final hasEvents = events.containsKey(_dateKey(date));

              return GestureDetector(
                onTap: () => setState(() => selectedDate = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [blue, violet], begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : null,
                    color: isSelected ? null : (isToday ? const Color(0xFFEDF1FF) : Colors.transparent),
                    borderRadius: BorderRadius.circular(13),
                    border: isToday && !isSelected ? Border.all(color: const Color(0xFFD8E1FF)) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected ? Colors.white : navy,
                          fontSize: 12,
                          fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasEvents
                              ? (isSelected ? Colors.white : const Color(0xFF6D5DF5))
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _monthButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFF2F4FC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 37, height: 37, child: Icon(icon, color: navy, size: 22)),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(color: violet, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          const Text('Ada agenda', style: TextStyle(color: Color(0xFF7D87A1), fontSize: 11)),
          const Spacer(),
          const Icon(Icons.touch_app_outlined, color: Color(0xFF9AA4BC), size: 15),
          const SizedBox(width: 5),
          const Text('Pilih tanggal untuk detail', style: TextStyle(color: Color(0xFF9AA4BC), fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _buildAgendaHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 13),
      child: Row(
        children: [
          const Expanded(
            child: Text('Agenda terpilih', style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
          ),
          Text(
            '${selectedDate.day} ${_monthName(selectedDate.month)}',
            style: const TextStyle(color: blue, fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(_CalendarEvent event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFEBEFF9)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF203B85).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(color: event.color.withOpacity(0.11), borderRadius: BorderRadius.circular(15)),
            child: Icon(event.icon, color: event.color, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(color: navy, fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.35)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF8993AC)),
                    const SizedBox(width: 5),
                    Text(event.time, style: const TextStyle(color: Color(0xFF7D87A1), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8993AC)),
                    const SizedBox(width: 5),
                    Expanded(child: Text(event.place, style: const TextStyle(color: Color(0xFF7D87A1), fontSize: 11))),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 4, height: 55, decoration: BoxDecoration(color: event.color, borderRadius: BorderRadius.circular(5))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 28),
      padding: const EdgeInsets.fromLTRB(23, 28, 23, 28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFE8EDFF), Color(0xFFF0EAFF)]),
            ),
            child: const Icon(Icons.event_available_rounded, color: blue, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada agenda', style: TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(
            'Tidak ada agenda yang tercatat pada ${selectedDate.day} ${_monthName(selectedDate.month)}. Nikmati waktumu atau tambahkan rencana baru.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7D87A1), fontSize: 11.5, height: 1.55),
          ),
          const SizedBox(height: 17),
          OutlinedButton.icon(
            onPressed: () => _showMessage('Form tambah agenda dapat dihubungkan pada tahap berikutnya.'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah agenda'),
            style: OutlinedButton.styleFrom(
              foregroundColor: blue,
              side: const BorderSide(color: Color(0xFFD8E1FF)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            ),
          ),
        ],
      ),
    );
  }

  int _monthEventCount() {
    return events.entries.where((entry) {
      final parts = entry.key.split('-');
      return int.parse(parts[0]) == displayedMonth.year &&
          int.parse(parts[1]) == displayedMonth.month;
    }).fold<int>(0, (sum, entry) => sum + entry.value.length);
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      displayedMonth = DateTime(now.year, now.month);
      selectedDate = DateTime(now.year, now.month, now.day);
    });
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

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}

class _CalendarEvent {
  final String title;
  final String time;
  final String place;
  final Color color;
  final IconData icon;

  const _CalendarEvent(this.title, this.time, this.place, this.color, this.icon);
}
