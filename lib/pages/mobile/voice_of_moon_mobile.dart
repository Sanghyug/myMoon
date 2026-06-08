// lib/pages/mobile/voice_of_moon_mobile.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/moon_ephemeris.dart';
import '../../utils/moon_phase_names.dart'; // (원래 코드의 import 유지)
import '../moon_result_page.dart'; // MoonResultPage 경로 확인!

class VoiceOfMoonMobile extends StatefulWidget {
  const VoiceOfMoonMobile({super.key});

  @override
  State<VoiceOfMoonMobile> createState() => _VoiceOfMoonMobileState();
}

class _VoiceOfMoonMobileState extends State<VoiceOfMoonMobile> {
  List<dynamic> _messages = [];
  List<dynamic> _fortunes = [];

  Map<String, dynamic>? _savedMoon; // ⭐ 저장된 달 정보

  @override
  void initState() {
    super.initState();
    _load();
    _loadSavedMoon();
  }

  // ---------------------------------------------------------------------------
  //  JSON 로드 (messages: 평평한(flat) 배열 150개)  — 기존 구조 그대로
  // ---------------------------------------------------------------------------
  Future<void> _load() async {
    final raw = jsonDecode(
      await rootBundle.loadString("assets/data/moon_messages.json"),
    );

    final flat = <Map<String, dynamic>>[];

    for (var group in raw["messages"]) {
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

    final fortuneJson = jsonDecode(
      await rootBundle.loadString("assets/data/moon_fortune_8x30.json"),
    );

    setState(() {
      _messages = flat;
      _fortunes = fortuneJson;
    });
  }

  // ---------------------------------------------------------------------------
  //  저장된 달 불러오기
  // ---------------------------------------------------------------------------
  Future<void> _loadSavedMoon() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("myMoon");
    if (raw != null) {
      setState(() {
        _savedMoon = jsonDecode(raw);
      });
    }
  }

  // ---------------------------------------------------------------------------
  //  생년월일 + 시간 선택 → MoonResultPage로 이동
  // ---------------------------------------------------------------------------
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: "생년월일 선택",
      locale: const Locale("ko", "KR"),
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

    if (_messages.isEmpty || _fortunes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("데이터를 불러오는 중입니다. 잠시 후 다시 시도해주세요.")),
      );
      return;
    }

    // 👉 팝업 대신 MoonResultPage로 풀스크린 이동
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MoonResultPage(
              birthDate: birth,
              moonMessages: _messages,
              moonFortunes: _fortunes,
            ),
      ),
    );

    // 돌아왔을 때 혹시 달이 새로 저장되었을 수 있으니 다시 로드
    _loadSavedMoon();
  }

  // ---------------------------------------------------------------------------
  //  저장된 달 카드 UI (moon_prophet 이미지 바로 아래에 표시)
  // ---------------------------------------------------------------------------
  Widget _buildSavedMoonCard() {
    final data = _savedMoon!;
    final msg = data["message"] ?? "";
    final preview = msg.length > 100 ? msg.substring(0, 100) + "..." : msg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "나의 달",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Image.asset(data["img"], height: 110),

          const SizedBox(height: 10),
          Text(
            data["nameEn"] ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          Text(
            data["nameKo"] ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 10),
          Text(
            "키워드 : ${data["keyword"] ?? ""}",
            style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
          ),

          const SizedBox(height: 12),
          Text(
            preview,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white70, height: 1.4, fontSize: 13),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              // 👉 전체 메시지/운세는 MoonResultPage에서 통합해서 보여줌
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MoonResultPage(
                        birthDate: DateTime.parse(data["birth"]),
                        moonMessages: _messages,
                        moonFortunes: _fortunes,
                      ),
                ),
              );
            },
            child: const Text("전체 메시지 & 오늘의 운세 보기"),
          ),

          const SizedBox(height: 6),

          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("myMoon");
              setState(() {
                _savedMoon = null;
              });
            },
            child: const Text(
              "내 달 삭제하기",
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  메인 UI  — 원래 Column 구조 유지
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final saved = _savedMoon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            "Voice of Moon",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 32),

        Center(
          child: Image.asset(
            "assets/images/moon_prophet.png",
            height: 180,
          ),
        ),

        const SizedBox(height: 16),

        if (saved != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSavedMoonCard(), // ⭐ 이미지 바로 아래에 나의 달 카드
          ),
        ] else
          ...[
            const Center(
              child: Text(
                "당신이 태어나던 순간의 달을 찾아보세요.",
                style: TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ],

        const SizedBox(height: 20),

        Center(
          child: ElevatedButton.icon(
            onPressed: _pickBirthDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(saved == null ? "생년월일 선택" : "다른 생년월일 입력하기"),
          ),
        ),

        const SizedBox(height: 30),

        const Center(
          child: Text(
            '달이 전하는 당신의 메시지와 오늘의 운세를 들을 수 있어요.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Image.asset(
            "assets/images/phases_of_the_moon.png",
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 60),
      ],
    );
  }
}
