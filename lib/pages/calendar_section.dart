import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;

import '../utils/moon_ephemeris.dart';
import '../utils/moon_phase_names.dart';

class CalendarSection extends StatefulWidget {
  final ScrollController? scrollController;

  const CalendarSection({super.key, this.scrollController});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection>
    with SingleTickerProviderStateMixin {

  // 🔥 전역 색상
  static const Color redWine = Color(0xFFAF6B8B);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final Map<String, String> _notes = {};

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ★ MoonEngine 계산 관련
  // ---------------------------------------------------------------------------
  // 기존 코드를 아래처럼 변경
  Map<String, dynamic> _moon(DateTime date) {
    final data = MoonEphemeris.calculate(date);
    return {
      "phaseIndex": data.phaseIndex,
      "illumination": data.illumination,
      "altitude": data.altitude,
      "azimuth": data.azimuth,
      "rise": data.rise,
      "set": data.set,
    };
  }

  // 남중 시점 방위각
  double _culminationAzimuth(DateTime date) {
    DateTime t = DateTime(date.year, date.month, date.day, 0);
    DateTime end = t.add(const Duration(days: 1));

    double maxAlt = -9999;
    double bestAz = 0;

    while (t.isBefore(end)) {
      final d = _moon(t);
      if (d["altitude"] > maxAlt) {
        maxAlt = d["altitude"];
        bestAz = d["azimuth"];
      }
      t = t.add(const Duration(minutes: 5));
    }
    return bestAz;
  }

  String _directionOfAz(double az) {
    if (az >= 45 && az < 135) return "동쪽하늘";
    if (az >= 135 && az < 225) return "남쪽하늘";
    if (az >= 225 && az < 315) return "서쪽하늘";
    return "북쪽하늘";
  }

  // 달 이모지
  String _phaseEmoji(int idx) {
    if (idx == 0 || idx == 29) return '🌑';
    if (idx < 7) return '🌒';
    if (idx < 9) return '🌓';
    if (idx < 15) return '🌔';
    if (idx == 15) return '🌕';
    if (idx < 22) return '🌖';
    if (idx < 26) return '🌗';
    if (idx < 29) return '🌘';
    return '🌑';
  }

  // 날짜 배경색
  Color _dayColorByPhase(DateTime date) {
    final idx = _moonIndex(date);
    final t = idx / 29.0;

    final d = 0.5 - 0.5 * math.cos(2 * math.pi * t);
    const bright = Color(0xFFBFC6CC);
    const dark = Color(0xFF3A3F45);

    int mix(int a, int b, double r) => (a + (b - a) * r).round();

    return Color.fromARGB(
      255,
      mix(bright.red, dark.red, d),
      mix(bright.green, dark.green, d),
      mix(bright.blue, dark.blue, d),
    );
  }

  // ⭐ 다시 정의해주는 계산 함수들
  int _moonIndex(DateTime date) =>
      MoonEphemeris
          .calculate(date)
          .phaseIndex;

  double _moonIllum(DateTime date) =>
      MoonEphemeris
          .calculate(date)
          .illumination;

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final holidays = _krHolidaysOfYear(_focusedDay.year);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lunar Calendar",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(1900, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            onDaySelected: (selected, focused) async {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              await _showPopup(selected);
            },
            rowHeight: 52,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) =>
                  _buildDayCell(day, holidays),
              todayBuilder: (context, day, _) =>
                  _buildDayCell(day, holidays, isToday: true),
              selectedBuilder: (context, day, _) =>
                  _buildDayCell(day, holidays, isSelected: true),
              outsideBuilder: (context, day, _) =>
                  _buildDayCell(day, holidays),
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            "배경색은 달의 주기 흐름을 반영합니다. 삭에 밝고, 보름에 어두워져요.",
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 날짜 셀
  // ---------------------------------------------------------------------------
  Widget _buildDayCell(DateTime day,
      Map<String, String> holidays, {
        bool isToday = false,
        bool isSelected = false,
      }) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final note = _notes[key];
    final holiday = holidays[key];

    final bg = _dayColorByPhase(day);
    final icon = _phaseEmoji(_moonIndex(day));

    // 날짜 숫자 색
    Color dateColor() {
      if (holiday != null) return redWine;
      if (day.weekday == DateTime.saturday ||
          day.weekday == DateTime.sunday) {
        return redWine;
      }
      return Colors.white;
    }

    final today = DateUtils.isSameDay(day, DateTime.now());

    return GestureDetector(
      onTap: () async => _showPopup(day),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: today
                ? Colors.greenAccent
                : isSelected
                ? Colors.amberAccent
                : Colors.white12,
            width: today ? 2.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 6,
              top: 4,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: dateColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Positioned(
              right: 6,
              top: 4,
              child: Text(icon, style: const TextStyle(fontSize: 14)),
            ),

            if (today)
              const Positioned(
                left: 6,
                bottom: 4,
                child: Text(
                  "오늘",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (holiday != null)
              const Positioned(
                left: 6,
                bottom: 4,
                child: Text(
                  "공휴일",
                  style: TextStyle(
                    color: redWine,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (note != null && note.isNotEmpty)
              const Positioned(
                right: 4,
                bottom: 2,
                child: Icon(Icons.event_note,
                    color: Colors.amberAccent, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 팝업
  // ---------------------------------------------------------------------------
  Future<void> _showPopup(DateTime date) async {
    final m = _moon(date);
    final idx = m["phaseIndex"];
    final rise = m["rise"];
    final set = m["set"];
    final illum = m["illumination"];
    final az = m["azimuth"];
    final alt = m["altitude"];

    final culAz = _culminationAzimuth(date);
    final direction = _directionOfAz(culAz);

    final nameKo = moonPhaseKo(idx);
    final nameEn = moonPhaseEn(idx);

    final key = DateFormat('yyyy-MM-dd').format(date);
    final controller = TextEditingController(text: _notes[key] ?? "");

    _controller
      ..reset()
      ..forward();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(18),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          DateFormat('y년 M월 d일 (E)', 'ko_KR').format(date),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Image.asset(
                          'assets/moon_phases/moon_${idx.toString().padLeft(
                              2, "0")}.png',
                          height: 140,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          nameEn,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        Text(
                          nameKo,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _info("조도", "${illum.toStringAsFixed(1)}%"),
                        _info("고도", "${alt.toStringAsFixed(0)}°"),
                        _info("방위각", "${az.toStringAsFixed(0)}°"),
                        _info("월출",
                            rise == null ? "-" : DateFormat('HH:mm').format(
                                rise)),
                        _info("월몰",
                            set == null ? "-" : DateFormat('HH:mm').format(
                                set)),
                        _info("관측 위치", direction),

                        const SizedBox(height: 14),

                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: '약속 / 메모 추가',
                            labelStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Color(0xFF2A2A2A),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 2,
                        ),

                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _notes[key] = controller.text;
                            });
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("저장"),
                        ),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("닫기",
                              style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 공휴일
  // ---------------------------------------------------------------------------
  Map<String, String> _krHolidaysOfYear(int year) {
    String k(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

    return {
      k(DateTime(year, 1, 1)): "신정",
      k(DateTime(year, 3, 1)): "삼일절",
      k(DateTime(year, 5, 5)): "어린이날",
      k(DateTime(year, 6, 6)): "현충일",
      k(DateTime(year, 8, 15)): "광복절",
      k(DateTime(year, 10, 3)): "개천절",
      k(DateTime(year, 10, 9)): "한글날",
      k(DateTime(year, 12, 25)): "성탄절",
    };
  }
}
