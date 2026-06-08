// lib/pages/mobile/header_section_mobile.dart

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async'; // ⭐ 에러 해결 1: Timer를 위해 반드시 필요합니다!

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../utils/moon_ephemeris.dart'; // 엔진 확인
import '../../utils/moon_phase_names.dart';

/// 방위값 → 텍스트
String _azToDir(double az, double alt) {
  String base;
  if (az >= 337.5 || az < 22.5) {
    base = "북쪽";
  } else if (az < 67.5) {
    base = "북동쪽";
  } else if (az < 112.5) {
    base = "동쪽";
  } else if (az < 157.5) {
    base = "남동쪽";
  } else if (az < 202.5) {
    base = "남쪽";
  } else if (az < 247.5) {
    base = "남서쪽";
  } else if (az < 292.5) {
    base = "서쪽";
  } else {
    base = "북서쪽";
  }

  return alt < 0 ? "$base (지평선 아래)" : base;
}

class HeaderSectionMobile extends StatefulWidget {
  const HeaderSectionMobile({super.key});

  @override
  State<HeaderSectionMobile> createState() => _HeaderSectionMobileState();
}

class _HeaderSectionMobileState extends State<HeaderSectionMobile> {
  late DateTime _now;
  late String _formattedDate;
  late String _formattedTime;

  late int _moonIdx;
  late double _azimuth;
  late double _altitude;
  late String _azDir;

  bool _showCompass = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _updateTime(); // 초기 로드

    // 1분마다 자동 갱신
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _formattedDate = DateFormat('y년 M월 d일 (E)', 'ko_KR').format(_now);
      _formattedTime = DateFormat('a h:mm', 'ko_KR').format(_now);

      final m = MoonEphemeris.calculate(_now);
      _moonIdx = m.phaseIndex;
      _azimuth = m.azimuth;
      _altitude = m.altitude;
      _azDir = _azToDir(_azimuth, _altitude);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameEn = moonPhaseEn(_moonIdx);
    final nameKo = moonPhaseKo(_moonIdx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 날짜 및 실시간 시계 표시
        Text(
          _formattedDate,
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        Text(
          _formattedTime,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),

        const SizedBox(height: 24),

        // 달 이미지 (실시간 위상 반영)
        LayoutBuilder(
          builder: (context, c) {
            final width = c.maxWidth;
            return Center(
              child: Container(
                width: math.max(220, width / 3),
                height: 140,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  'assets/moon_phases/moon_${_moonIdx.toString().padLeft(
                      2, '0')}.png',
                  height: 120,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        Text(
          nameEn,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nameKo,
          style: const TextStyle(fontSize: 15, color: Colors.white70),
        ),

        const SizedBox(height: 20),

        // 관측 방위 실시간 텍스트
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "관측 방위 : $_azDir",
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _showCompass ? Icons.explore : Icons.explore_outlined,
                color: Colors.white70,
                size: 20,
              ),
              tooltip: '나침반 열기',
              onPressed: () {
                setState(() {
                  _showCompass = !_showCompass;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 📈 실시간 고도 그래프 (현재 시각 점선이 이동함)
        _MoonRiseSetGraph(now: _now),

        if (_showCompass) ...[
          const SizedBox(height: 12),
          // 🧭 실시간 나침반 데이터 전달
          CompassWidget(
            moonAzimuth: _azimuth,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------------
// 그래프 섹션 (MoonEngineV2 기반)
// ------------------------------------------------------------------

class _MoonRiseSetGraph extends StatelessWidget {
  final DateTime now;

  const _MoonRiseSetGraph({required this.now});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: 120,
          child: CustomPaint(
            painter: _MoonPathPainter(now: now),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "앱이 제공하는 달 데이터는 MoonEngine_v2 기반입니다.",
          style: TextStyle(fontSize: 11, color: Colors.white60),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MoonPathPainter extends CustomPainter {
  final DateTime now;

  _MoonPathPainter({required this.now});

  @override
  void paint(Canvas canvas, Size size) {
    // ───────────────────────────────────────────────
    // 기본 선 스타일
    // ───────────────────────────────────────────────
    final horizonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF444444); // 지평선

    final visiblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white; // 달이 보이는 경로

    final hiddenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF666666); // 숨은 경로

    final nowLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFAAAAAA); // 현재시간 점선

    final nowDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD54F); // 현재 달 위치 점

    // ───────────────────────────────────────────────
    // Y 범위 설정
    // ───────────────────────────────────────────────
    final baseY = size.height * 0.70; // 지평선
    final topY = size.height * 0.20; // 가장 높은 고도

    // ───────────────────────────────────────────────
    // 지평선
    // ───────────────────────────────────────────────
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), horizonPaint);

    // ───────────────────────────────────────────────
    // 달 이동 경로 계산
    // ───────────────────────────────────────────────
    final visiblePath = Path();
    final hiddenPath = Path();

    const steps = 48; // 30분 간격 → 하루 24시간
    Offset? prevPt;
    bool? prevVisible;

    for (int i = 0; i <= steps; i++) {
      final minutes = (24 * 60 / steps * i).round();

      // t = i번째 시간
      final t = DateTime(now.year, now.month, now.day)
          .add(Duration(minutes: minutes));

      final m = MoonEphemeris.calculate(t);
      final alt = m.altitude;

      // alt = 고도값, y 위치 매핑
      double norm = ((alt + 5) / 90).clamp(0.0, 1.0);
      double y = alt < 0 ? baseY : baseY - (baseY - topY) * norm;

      final x = size.width * (minutes / (24 * 60));
      final pt = Offset(x, y);
      final visible = alt >= 0;

      if (visible) {
        if (prevVisible == true) {
          visiblePath.lineTo(x, y);
        } else {
          if (prevPt != null) {
            visiblePath.moveTo(prevPt!.dx, prevPt!.dy);
          }
          visiblePath.lineTo(x, y);
        }
      } else {
        if (prevVisible == false) {
          hiddenPath.lineTo(x, y);
        } else {
          if (prevPt != null) {
            hiddenPath.moveTo(prevPt!.dx, prevPt!.dy);
          }
          hiddenPath.lineTo(x, y);
        }
      }

      prevPt = pt;
      prevVisible = visible;
    }

    // 실제 경로 그리기
    canvas.drawPath(hiddenPath, hiddenPaint);
    canvas.drawPath(visiblePath, visiblePaint);

    // ───────────────────────────────────────────────
    // 현재 시각 세로 점선 + 현재 달 위치 점
    // ───────────────────────────────────────────────

    final nowMinutes = now.hour * 60 + now.minute;
    final nowX = size.width * (nowMinutes / (24 * 60));

    // (1) 세로 점선
    _drawDashedLine(
      canvas,
      Offset(nowX, topY),
      Offset(nowX, baseY),
      nowLinePaint,
      dashLength: 4,
      gapLength: 4,
    );

    // (2) 현재 달 위치 dot
    // 1. 먼저 'nowM'이라는 이름으로 달 데이터를 계산합니다. (아까 fifinal이었던 부분)
    final nowM = MoonEphemeris.calculate(now);

// 2. 계산된 'nowM'에서 고도(altitude)를 가져옵니다.
    final alt = nowM.altitude;

    if (alt >= 0) {
      final norm = ((alt + 5) / 90).clamp(0.0, 1.0);
      final nowY = baseY - (baseY - topY) * norm;
      canvas.drawCircle(Offset(nowX, nowY), 4, nowDotPaint);
    }

    // ───────────────────────────────────────────────
    // X축 3시간 단위 눈금
    // ───────────────────────────────────────────────

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    const hourStep = 3;
    for (int h = 0; h <= 24; h += hourStep) {
      final x = size.width * (h / 24);

      // 눈금선
      canvas.drawLine(
        Offset(x, baseY),
        Offset(x, baseY + 4),
        horizonPaint,
      );

      // 시간 텍스트
      final label = h.toString();
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 9, color: Colors.white60),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, baseY + 6),
      );
    }
  }

  // ───────────────────────────────────────────────
  // 점선 그리는 헬퍼
  // ───────────────────────────────────────────────
  void _drawDashedLine(Canvas canvas,
      Offset from,
      Offset to,
      Paint paint, {
        required double dashLength,
        required double gapLength,
      }) {
    final totalLength = (to - from).distance;
    final direction = (to - from) / totalLength;
    double distance = 0;

    while (distance < totalLength) {
      final start = from + direction * distance;
      final end =
          from + direction * (distance + dashLength).clamp(0, totalLength);
      canvas.drawLine(start, end, paint);
      distance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPathPainter oldDelegate) {
    return oldDelegate.now != now;
  }
}

// ------------------------------------------------------------------
// ⭐ 나침반 위젯 (동서남북 고정 + 달 방향 + 자기장 바늘)
// ------------------------------------------------------------------

class CompassWidget extends StatefulWidget {
  final double moonAzimuth;

  const CompassWidget({super.key, required this.moonAzimuth});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double? _deviceHeading;

  @override
  void initState() {
    super.initState();

    FlutterCompass.events!.listen((event) {
      if (!mounted) return;
      setState(() {
        _deviceHeading = event.heading; // 센서 없으면 null 들어옴
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = 180.0;

    // ⭐ 센서 없음 → null
    if (_deviceHeading == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "나침반 센서를 사용할 수 없습니다.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final heading = _deviceHeading!;
    final moonAngle = widget.moonAzimuth * math.pi / 180;
    final phoneRotation = heading * math.pi / 180;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF111111),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 고정 눈금
            CustomPaint(
              size: Size(size, size),
              painter: _FixedCompassDialPainter(),
            ),

            // 달 위치 바늘
            Transform.rotate(
              angle: moonAngle,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.topCenter,
                child: Container(
                  width: 5,
                  height: size * 0.30,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            // 빨간+흰 바늘
            Transform.rotate(
              angle: -phoneRotation,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _CompassNeedlePainter(),
                ),
              ),
            ),

            // 중심 점
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _FixedCompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - 2, paint);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    final labels = ["N", "E", "S", "W"];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final dx = center.dx + (radius - 20) * math.sin(angle);
      final dy = center.dy - (radius - 20) * math.cos(angle);

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(dx - textPainter.width / 2, dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ───────────────────────────────
    // 위쪽 빨간 바늘 (북쪽)
    // ───────────────────────────────
    final north = Path()
      ..moveTo(center.dx, center.dy - 70)
      ..lineTo(center.dx - 12, center.dy)..lineTo(center.dx + 12, center.dy)
      ..close();

    final northPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    canvas.drawPath(north, northPaint);

    // ───────────────────────────────
    // 아래쪽 흰색 바늘 (남쪽)
    // ───────────────────────────────
    final south = Path()
      ..moveTo(center.dx, center.dy + 70)
      ..lineTo(center.dx - 12, center.dy)..lineTo(center.dx + 12, center.dy)
      ..close();

    final southPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(south, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

