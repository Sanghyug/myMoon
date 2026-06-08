import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../utils/moon_ephemeris.dart'; // [cite: 823]
import '../utils/moon_phase_names.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  late DateTime _now;
  late String _formattedDate;
  late String _formattedTime;

  late int _moonIdx;
  late double _illum;
  late double _az;
  late double _alt;
  late DateTime? _rise;
  late DateTime? _set;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  void _hydrate() {
    _now = DateTime.now();
    _formattedDate = DateFormat('y년 M월 d일 (E)', 'ko_KR').format(_now);
    _formattedTime = DateFormat('a h:mm', 'ko_KR').format(_now);

    // ⭐ 가장 정확한 MoonEphemeris로 계산합니다. [cite: 823]
    final data = MoonEphemeris.calculate(_now);

    _moonIdx = data.phaseIndex; // 0~29 사이의 숫자 [cite: 817, 821]
    _illum = data.illumination; // 달의 밝기 (%) [cite: 818, 821]
    _az = data.azimuth; // 방위각 [cite: 817, 821]
    _alt = data.altitude; // 고도 [cite: 817, 821]
    _rise = data.rise; // 달이 뜨는 시간 [cite: 817, 821]
    _set = data.set; // 달이 지는 시간 [cite: 817, 821]
  }

  String _directionOfAz(double az) {
    if (az >= 45 && az < 135) return '동쪽 하늘';
    if (az >= 135 && az < 225) return '남쪽 하늘';
    if (az >= 225 && az < 315) return '서쪽 하늘';
    return '북쪽 하늘';
  }

  @override
  Widget build(BuildContext context) {
    final phaseEn = moonPhaseEn(_moonIdx);
    final phaseKo = moonPhaseKo(_moonIdx);
    final dir = _directionOfAz(_az);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '오늘, 나의 달',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            _formattedDate,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _formattedTime,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 20),

          const Text(
            '“당신의 달은 지금 이 순간도 당신의 주위를 돌고 있습니다.”',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 26),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Container(
                width: math.max(220, width / 3),
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/moon_phases/moon_${_moonIdx.toString().padLeft(
                      2, '0')}.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Text(
            phaseEn,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phaseKo,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),

          const SizedBox(height: 8),

          Text(
            '조도 ${_illum.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 14, color: Colors.white54),
          ),

          Text(
            '관측 기준: 서울  |  방위각 ${_az.toStringAsFixed(0)}°  |  고도 ${_alt
                .toStringAsFixed(0)}°',
            style: const TextStyle(fontSize: 14, color: Colors.white54),
          ),

          const SizedBox(height: 8),

          Text(
            '현재 달은 $dir 방향에 있습니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),

          const SizedBox(height: 26),

          _buildMoonPathArea(),
        ],
      ),
    );
  }

  Widget _buildMoonPathArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 110,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: CustomPaint(
                painter: _MoonPathPainter(now: _now),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "앱이 제공하는 달 데이터는 MoonEngine_v2 기반 계산입니다.\n"
                "위치에 따라 월출/월몰은 약 ±3~5분, 위상은 ±1% 차이가 있을 수 있습니다.",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white54,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------
// Moon Path Painter (MoonEngineV2 적용)
// --------------------------------------------------------------

class _MoonPathPainter extends CustomPainter {
  final DateTime now;

  _MoonPathPainter({required this.now});

  @override
  void paint(Canvas canvas, Size size) {
    final horizonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF444444);

    final visiblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFFFFF);

    final hiddenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFF666666);

    final nowLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFAAAAAA);

    final nowDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD54F);

    final baseY = size.height * 0.65;
    final topY = size.height * 0.15;

    // ------------------------------
    // 1) 수평선 (지평선)
    // ------------------------------
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), horizonPaint);

    // ------------------------------
    // 2) 달 이동 경로 표기
    // ------------------------------
    final visiblePath = Path();
    final hiddenPath = Path();

    final date = DateTime(now.year, now.month, now.day);
    const steps = 48;

    Offset? prevPt;
    bool? prevVisible;

    for (int i = 0; i <= steps; i++) {
      final minutes = (24 * 60 / steps * i).round();
      final t = date.add(Duration(minutes: minutes));

      final m = MoonEphemeris.calculate(t);
      final alt = m.altitude;

      final norm = ((alt + 5) / 90).clamp(0.0, 1.0);
      double y = alt < 0 ? baseY : baseY - (baseY - topY) * norm;

      final x = size.width * (minutes / (24 * 60));
      final pt = Offset(x, y);
      final visible = alt >= 0;

      if (prevPt == null) {
        visible ? visiblePath.moveTo(pt.dx, pt.dy) : hiddenPath.moveTo(
            pt.dx, pt.dy);
      } else {
        if (visible) {
          if (prevVisible == true) {
            visiblePath.lineTo(pt.dx, pt.dy);
          } else {
            visiblePath.moveTo(prevPt.dx, prevPt.dy);
            visiblePath.lineTo(pt.dx, pt.dy);
          }
        } else {
          if (prevVisible == false) {
            hiddenPath.lineTo(pt.dx, pt.dy);
          } else {
            hiddenPath.moveTo(prevPt.dx, prevPt.dy);
            hiddenPath.lineTo(pt.dx, pt.dy);
          }
        }
      }

      prevPt = pt;
      prevVisible = visible;
    }

    canvas.drawPath(hiddenPath, hiddenPaint);
    canvas.drawPath(visiblePath, visiblePaint);

    // ------------------------------
    // 3) 현재 시간 점선 + 점 표시
    // ------------------------------
    final nowMin = now.hour * 60 + now.minute;
    final nowX = size.width * (nowMin / (24 * 60));

    _drawDashedLine(
        canvas, Offset(nowX, topY), Offset(nowX, baseY), nowLinePaint);

    final nowM = MoonEphemeris.calculate(now);
    final altNow = nowM.altitude;
    if (altNow >= 0) {
      final norm = ((altNow + 5) / 90).clamp(0.0, 1.0);
      final y = baseY - (baseY - topY) * norm;
      canvas.drawCircle(Offset(nowX, y), 4, nowDotPaint);
    }

    // ------------------------------
    // 4) 추가됨: 3시간 단위 시간 눈금
    // ------------------------------
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr
    );


    for (int h = 0; h <= 24; h += 3) {
      final x = size.width * (h / 24);
      canvas.drawLine(
          Offset(x, baseY), Offset(x, baseY + 6),
          Paint()
            ..color = Colors.white38
            ..strokeWidth = 1);

      textPainter.text = TextSpan(
        text: "$h시",
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 10,
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, baseY + 8));
    }

    // ------------------------------
    // 5) 추가됨: 상단 방위 텍스트 표시
    // ------------------------------
    const directions = ["E", "SE", "S", "SW", "W"];
    const dirDegrees = [90, 135, 180, 225, 270];

    for (int i = 0; i < directions.length; i++) {
      final x = size.width * (dirDegrees[i] / 360);
      final label = directions[i];

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, topY - 18));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint,
      {double dashLength = 4, double gapLength = 4}) {
    final distance = (to - from).distance;
    final dir = (to - from) / distance;

    double drawn = 0;
    while (drawn < distance) {
      final start = from + dir * drawn;
      final end = from + dir * math.min(drawn + dashLength, distance);
      canvas.drawLine(start, end, paint);
      drawn += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPathPainter oldDelegate) {
    return oldDelegate.now != now;
  }
}

