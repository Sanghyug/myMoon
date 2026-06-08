import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ⭐ 추가됨
import 'firebase_options.dart';

import 'pages/mobile/header_section_mobile.dart';
import 'pages/mobile/calendar_section_mobile.dart';
import 'pages/mobile/voice_of_moon_mobile.dart';
import 'pages/mobile/knowledge_section_mobile.dart'; // ⭐ 추가
import 'pages/mobile/board_section_mobile.dart'; // ⭐ 추가

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko', null);

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } catch (e) {
    Firebase.app();
  }

  runApp(const MeaLunaWhisperApp());
}

class MeaLunaWhisperApp extends StatelessWidget {
  const MeaLunaWhisperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mea Luna Whisper',

      // ⭐ 여기에 localization 설정 추가됨 ⭐
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E0E10),
        primaryColor: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: const MobileHomePage(),
    );
  }
}

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // --------------------------
              //    APP ICON + Whisper
              // --------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/mealuna_logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Whisper",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --------------------------
              //      오늘, 나의 달
              // --------------------------
              const Text(
                "오늘, 나의 달",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 26),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: HeaderSectionMobile(),
              ),

              const Divider(color: Colors.white12, height: 60), // 구분선 추가

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CalendarSectionMobile(),
              ),

              const Divider(color: Colors.white12, height: 60),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: VoiceOfMoonMobile(),
              ),

              const Divider(color: Colors.white12, height: 60),

              // ⭐ 새로 추가된 지식 섹션
              const KnowledgeSectionMobile(),

              const Divider(color: Colors.white12, height: 60),

              // ⭐ 새로 추가된 게시판 섹션
              const BoardSectionMobile(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
