import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;

import '../../utils/moon_ephemeris.dart';
import '../../utils/moon_phase_names.dart';

class CalendarSectionMobile extends StatefulWidget {
  const CalendarSectionMobile({super.key});

  @override
  State<CalendarSectionMobile> createState() => _CalendarSectionMobileState();
}

class _CalendarSectionMobileState extends State<CalendarSectionMobile> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildCalendarGrid(),
      ],
    );
  }

  // ---------------------------------------------------------
  // 캘린더 상단 (월 이동)
  // ---------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            setState(() {
              _focusedDay =
                  DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
            });
          },
        ),
        Text(
          DateFormat('y년 M월', 'ko_KR').format(_focusedDay),
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          onPressed: () {
            setState(() {
              _focusedDay =
                  DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
            });
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // 모바일 캘린더 UI
  // ---------------------------------------------------------
  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDay.weekday % 7; // 일(0) ~ 토(6)
    final totalDays = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;

    final rows = <Widget>[];
    int dayCursor = 1 - firstWeekday;

    for (int week = 0; week < 6; week++) {
      final cells = <Widget>[];

      for (int wd = 0; wd < 7; wd++) {
        if (dayCursor < 1 || dayCursor > totalDays) {
          cells.add(_buildEmptyCell());
        } else {
          final date = DateTime(_focusedDay.year, _focusedDay.month, dayCursor);
          cells.add(_buildDayCell(date));
        }
        dayCursor++;
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: cells,
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildEmptyCell() {
    return Container(
      width: 48,
      height: 58,
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }

  // ---------------------------------------------------------
  // 날짜 셀
  // ---------------------------------------------------------
  Widget _buildDayCell(DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final moon = MoonEphemeris.calculate(date);
    final idx = moon.phaseIndex;
    final img = 'assets/moon_phases/moon_${idx.toString().padLeft(2, '0')}.png';

    return GestureDetector(
      onTap: () => _openPopup(date),
      child: Container(
        width: 48,
        height: 58,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isToday ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                color: isToday ? Colors.yellowAccent : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Image.asset(img, width: 26, height: 26, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 팝업: 선택 날짜의 달 정보
  // ---------------------------------------------------------
  void _openPopup(DateTime date) {
    final m = MoonEphemeris.calculate(date);
    final idx = m.phaseIndex;
    final illum = m.illumination;
    final az = m.azimuth;
    final alt = m.altitude;
    final rise = m.rise;
    final set = m.set;

    final phaseEn = moonPhaseEn(idx);
    final phaseKo = moonPhaseKo(idx);
    final img = 'assets/moon_phases/moon_${idx.toString().padLeft(2, '0')}.png';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0F1A24),
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(img, height: 110, fit: BoxFit.contain),
                const SizedBox(height: 10),

                Text(
                  phaseEn,
                  style: const TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  phaseKo,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 12),

                Text(
                  DateFormat('y년 M월 d일 (E)', 'ko_KR').format(date),
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 16),

                _infoRow("조도", "${illum.toStringAsFixed(1)}%"),
                _infoRow("고도", "${alt.toStringAsFixed(0)}°"),
                _infoRow("방위각", "${az.toStringAsFixed(0)}°"),
                _infoRow("월출",
                    rise == null ? "-" : DateFormat('a h:mm', "ko_KR").format(
                        rise)),
                _infoRow("월몰",
                    set == null ? "-" : DateFormat('a h:mm', "ko_KR").format(
                        set)),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                      "닫기", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
          Text(
              value, style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }
}
