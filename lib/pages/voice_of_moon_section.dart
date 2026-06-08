// lib/pages/voice_of_moon_section.dart
// 2025-11 — MoonEngineV2 통합 / 메시지 시스템 최신화 버전

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/moon_ephemeris.dart';
import '../utils/moon_phase_names.dart';

class VoiceOfMoonSection extends StatefulWidget {
  const VoiceOfMoonSection({super.key});

  @override
  State<VoiceOfMoonSection> createState() => _VoiceOfMoonSectionState();
}

class _VoiceOfMoonSectionState extends State<VoiceOfMoonSection> {
  List<dynamic> _moonMessages = [];
  List<dynamic> _moonFortunes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // -----------------------------------------------------
  // 📥 메시지·운세 JSON 로딩
  // -----------------------------------------------------
  Future<void> _loadData() async {
    final msgRaw =
    jsonDecode(await rootBundle.loadString('assets/data/moon_messages.json'));

    final fortuneData =
    jsonDecode(
        await rootBundle.loadString('assets/data/moon_fortune_8x30.json'));

    // messages는 2중 배열 → flatten
    final flat = <Map<String, dynamic>>[];
    for (var group in msgRaw["messages"]) {
      if (group is List) {
        for (var item in group) {
          flat.add({
            "age": int.tryParse(item["age"].toString()) ?? 0,
            "distance": int.tryParse(item["distance"].toString()) ?? 0,
            "phase": item["phase"],
            "keyword": item["keyword"],
            "message": item["message"],
            "reason": item["reason"],
          });
        }
      }
    }

    setState(() {
      _moonMessages = flat;
      _moonFortunes = fortuneData;
    });
  }

  // -----------------------------------------------------
  // 🌓 distance 계산 (0~4) — 기존 피선생 방식 유지
  // -----------------------------------------------------
  int _distanceIndex(DateTime date) {
    final hour = date.hour + date.minute / 60.0;
    final diffFromMid = hour <= 12 ? hour : 24 - hour;
    final t = diffFromMid / 12.0;

    if (t < 0.2) return 0;
    if (t < 0.4) return 1;
    if (t < 0.6) return 2;
    if (t < 0.8) return 3;
    return 4;
  }

  // -----------------------------------------------------
  // 🌙 월령+distance로 메시지 찾기 (150개 중)
  // -----------------------------------------------------
  Map<String, dynamic> _findMessage(int age, int dist) {
    return _moonMessages.firstWhere(
          (m) => m["age"] == age && m["distance"] == dist,
      orElse: () =>
      {
        "keyword": "",
        "message": "메시지를 찾을 수 없습니다.",
        "reason": "",
      },
    );
  }

  // -----------------------------------------------------
  // 📅 생년월일 + 시간 입력
  // -----------------------------------------------------
  Future<void> _pickBirthDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: DateTime(now.year - 20),
      helpText: "생년월일 선택",
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: "태어난 시간 선택",
    );
    if (pickedTime == null) return;

    final birth = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (_moonMessages.isEmpty) return;

    // MoonEngineV2 월령 통일
    final age = MoonEphemeris
        .calculate(birth)
        .phaseIndex;
    final dist = _distanceIndex(birth);

    _showBirthPopup(birth, age, dist);
  }

  // -----------------------------------------------------
  // 🌕 나의 달 메시지 팝업
  // -----------------------------------------------------
  void _showBirthPopup(DateTime date, int age, int dist) {
    final data = _findMessage(age, dist);
    final keyword = data["keyword"] ?? "";
    final message = data["message"] ?? "";
    final reason = data["reason"] ?? "";
    final nameEn = moonPhaseEn(age);
    final nameKo = moonPhaseKo(age);
    final img = "assets/moon_phases/moon_${age.toString().padLeft(2, '0')}.png";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) =>
          Dialog(
            insetPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 24),
            backgroundColor: Colors.transparent,
            child: Center(
              child: Container(
                width: 450, // ⭐ 가로폭 제한
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ⭐ 세로 길이 최적화
                    children: [
                      Text(
                        "${date.year}년 ${date.month}월 ${date.day}일  "
                            "${date.hour.toString().padLeft(2, '0')}시 "
                            "${date.minute.toString().padLeft(2, '0')}분",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.asset(img, height: 140),
                      const SizedBox(height: 16),
                      Text(nameEn,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(nameKo,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15)),
                      const SizedBox(height: 14),
                      Text(
                        "키워드 : $keyword",
                        style: const TextStyle(
                            color: Colors.amberAccent, fontSize: 15),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        message,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 15, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        reason,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showLoadingThenFortune(age);
                        },
                        child: const Text("오늘의 운세 보기"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  // -----------------------------------------------------
  // ⏳ 로딩 → 운세
  // -----------------------------------------------------
  void _showLoadingThenFortune(int age) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(ctx);
          _showFortunePopup(age);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: Colors.white54),
                SizedBox(height: 14),
                Text(
                  "무료 서비스입니다.\n광고 하나만 보고 기다려주세요...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------
  // 🎯 행운지수 계산
  // -----------------------------------------------------
  int _calcLucky(int birthAge, int todayAge) {
    final diff = (birthAge - todayAge).abs();
    final raw = (100 - diff * 3).clamp(50, 100);
    return raw;
  }

  // -----------------------------------------------------
  // 🍀 운세 선택 (8×30 조합)
  // -----------------------------------------------------
  String _pickFortune(int todayAge) {
    if (_moonFortunes.isEmpty) {
      return "오늘은 작은 변화가 새로운 길을 열 수 있습니다.";
    }

    final type = Random().nextInt(8);

    final f = _moonFortunes.firstWhere(
          (x) => x["user_type"] == type && x["today_phase"] == todayAge,
      orElse: () => {"fortune": "오늘은 조용한 흐름 속에서 기회가 자랍니다."},
    );

    return f["fortune"] ?? "";
  }

  // -----------------------------------------------------
  // 🌟 오늘의 운세 팝업
  // -----------------------------------------------------
  void _showFortunePopup(int birthAge) {
    final todayPhase = MoonEphemeris
        .calculate(DateTime.now())
        .phaseIndex;
    final score = _calcLucky(birthAge, todayPhase);
    final fortune = _pickFortune(todayPhase);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) =>
          Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: Colors.transparent,
            child: Center(
              child: Container(
                width: 380, // ⭐ 운세는 조금 더 아담하게
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ⭐ 내용만큼만 높이 차지
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/moon_prophet_face.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "오늘의 운세",
                      style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "오늘의 행운지수 : $score점",
                      style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fortune,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 15, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                          "닫기", style: TextStyle(color: Colors.white70)),
                    )
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // -----------------------------------------------------
  // 🎨 메인 UI
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Voice of Moon",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),
        Image.asset("assets/images/moon_prophet.png", height: 190),

        const SizedBox(height: 18),
        const Text(
          "당신이 태어나던 순간의 달을 찾아보세요.",
          style: TextStyle(color: Colors.white70, fontSize: 15),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 22),
        ElevatedButton.icon(
          onPressed: _pickBirthDateTime,
          icon: const Icon(Icons.calendar_month),
          label: const Text("생년월일 선택"),
        ),

        const SizedBox(height: 26),
        const Text(
          "달이 전하는 메시지와 오늘의 운세를 들을 수 있어요.",
          style: TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.asset(
            "assets/images/phases_of_the_moon.png",
            width: MediaQuery
                .of(context)
                .size
                .width * 0.9,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 160),
      ],
    );
  }
}
