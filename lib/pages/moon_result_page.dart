import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert'; // ⭐ 추가
import 'package:shared_preferences/shared_preferences.dart'; // ⭐ 추가

import '../utils/moon_ephemeris.dart';
import '../utils/moon_phase_names.dart';

class MoonResultPage extends StatelessWidget {
  final DateTime birthDate;
  final List<dynamic> moonMessages;
  final List<dynamic> moonFortunes;

  const MoonResultPage({
    super.key,
    required this.birthDate,
    required this.moonMessages,
    required this.moonFortunes,
  });

  // -----------------------------------------------------
  // 🌙 월령 = MoonEngine 기준 통일  (원본 그대로)
  // -----------------------------------------------------
  int _moonIndex(DateTime date) {
    // 이제 수식으로 정확하게 계산한 인덱스를 가져옵니다. [cite: 821]
    return MoonEphemeris
        .calculate(date)
        .phaseIndex;
  }

  // -----------------------------------------------------
  // 🌓 distance = VoiceOfMoon 규칙과 동일 (원본 그대로)
  // -----------------------------------------------------
  int _distanceIndex(DateTime date) {
    final hour = date.hour + date.minute / 60.0;

    final diff = hour <= 12 ? hour : 24 - hour;
    final t = diff / 12.0;

    if (t < 0.2) return 0;
    if (t < 0.4) return 1;
    if (t < 0.6) return 2;
    if (t < 0.8) return 3;
    return 4;
  }

  // -----------------------------------------------------
  // 🌙 age + distance → 메시지 찾기 (원본 그대로)
  // -----------------------------------------------------
  Map<String, dynamic> _findMessage(int age, int distance) {
    return moonMessages.firstWhere(
          (m) => m["age"] == age && m["distance"] == distance,
      orElse: () =>
      {
        "message": "메시지를 찾을 수 없습니다.",
        "reason": "",
        "keyword": "",
      },
    );
  }

  // -----------------------------------------------------
  // ✨ 행운지수 계산 (VoiceOfMoon과 동일, 원본 그대로)
  // -----------------------------------------------------
  int _calcLuckyScore(int birthAge, int todayAge) {
    final phaseMap = {
      0: 20, 1: 30, 2: 40, 3: 40, 4: 45, 5: 50,
      6: 55, 7: 60, 8: 65, 9: 70, 10: 75, 11: 80,
      12: 85, 13: 90, 14: 95, 15: 95, 16: 85, 17: 75,
      18: 70, 19: 60, 20: 55, 21: 50, 22: 45, 23: 40,
      24: 35, 25: 30, 26: 30, 27: 30, 28: 30, 29: 30
    };

    final phaseScore = phaseMap[todayAge] ?? 50;
    final diff = (birthAge - todayAge).abs();
    final compat = (100 - diff * 3).clamp(0, 100);

    final raw = ((phaseScore + compat) / 2).round();
    return max(raw, 50);
  }

  // -----------------------------------------------------
  // ✨ 운세 문구 선택 (원본 그대로)
  // -----------------------------------------------------
  String _pickFortune(int todayAge) {
    if (moonFortunes.isEmpty) return "오늘은 작은 움직임 속에서 빛이 납니다.";

    final rand = Random();
    final userType = rand.nextInt(8);

    final match = moonFortunes.firstWhere(
          (f) => f["user_type"] == userType && f["today_phase"] == todayAge,
      orElse: () => {"fortune": "조용한 흐름 속에서 기회가 다가옵니다."},
    );

    return match["fortune"];
  }

  // -----------------------------------------------------
  // ⭐ 내 달 저장 기능 (새로 추가)
  //    - VoiceOfMoonMobile이 불러오는 구조와 동일하게 저장
  // -----------------------------------------------------
  Future<void> _saveMyMoon({
    required BuildContext context,
    required int age,
    required int distance,
    required Map<String, dynamic> msg,
    required String nameEn,
    required String nameKo,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      "birth": birthDate.toIso8601String(),
      "age": age,
      "distance": distance,
      "keyword": msg["keyword"] ?? "",
      "message": msg["message"] ?? "",
      "reason": msg["reason"] ?? "",
      "nameEn": nameEn,
      "nameKo": nameKo,
      "img": "assets/moon_phases/moon_${age.toString().padLeft(2, '0')}.png",
    };

    await prefs.setString("myMoon", jsonEncode(data));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("나의 달이 저장되었습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = _moonIndex(birthDate);
    final distance = _distanceIndex(birthDate);

    final msg = _findMessage(age, distance);

    final nameEn = moonPhaseEn(age);
    final nameKo = moonPhaseKo(age);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("태어난 날의 달"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Text(
              "${birthDate.year}.${birthDate.month}.${birthDate.day}",
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Image.asset(
              "assets/moon_phases/moon_${age.toString().padLeft(2, '0')}.png",
              height: 160,
            ),
          ),

          const SizedBox(height: 16),

          Column(
            children: [
              Text(
                nameEn,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nameKo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            "그날 밤, 당신을 비추던 달은 이렇게 말하고 있었습니다.",
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          /// 메시지
          Text(
            msg["message"] ?? "",
            style: const TextStyle(
                fontSize: 17, color: Colors.white, height: 1.5),
          ),

          const SizedBox(height: 20),

          /// 근거
          Text(
            msg["reason"] ?? "",
            style: const TextStyle(
                fontSize: 15, color: Colors.white60, height: 1.4),
          ),

          const SizedBox(height: 40),

          /// ⭐ 내 달 저장하기 버튼 (새로 추가)
          ElevatedButton(
            onPressed: () =>
                _saveMyMoon(
                  context: context,
                  age: age,
                  distance: distance,
                  msg: msg,
                  nameEn: nameEn,
                  nameKo: nameKo,
                ),
            child: const Text("내 달 저장하기"),
          ),

          const SizedBox(height: 16),

          /// 오늘의 운세 보기 (원본 그대로, 행운지수 로직 유지)
          ElevatedButton(
            onPressed: () {
              final todayAge =
                  MoonEphemeris
                      .calculate(DateTime.now())
                      .phaseIndex;

              final score = _calcLuckyScore(age, todayAge);
              final fortune = _pickFortune(todayAge);

              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) =>
                    Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101010),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "오늘의 운세",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              "오늘의 행운지수 : $score점",
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              fortune,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                '닫기',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
              );
            },
            child: const Text("오늘의 운세 보기"),
          ),
        ],
      ),
    );
  }
}
