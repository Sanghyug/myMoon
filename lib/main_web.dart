// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; //
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui; // ⭐ 'dart:ui_web'을 'ui'라는 이름으로 가져옵니다
import 'package:flutter/material.dart'; //

import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/admin_page.dart'; // ⭐ 새로 만든 파일을 불러옵니다.
import 'firebase_options.dart';
import 'pages/header_section.dart';
import 'pages/calendar_section.dart';
import 'pages/mymoon_section.dart';
import 'pages/orbit_section.dart';
import 'pages/knowledge_section.dart';
import 'pages/board_section.dart';

bool _iframeRegistered = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);

  // ⭐ 이제 수식으로 직접 계산하므로 이 줄(loadMoonAgeDB)은 필요 없습니다.

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Web iframe 등록
  ui.platformViewRegistry.registerViewFactory(
    'orbit-iframe',
        (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'assets/web_assets/orbit3d_horizons.html'
        ..style.border = 'none'
        ..style.width = '100%' // ⭐ style.width 추가
        ..style.height = '100%' // ⭐ style.height 추가
        ..width = '100%'
        ..height = '520';
      return iframe;
    },
  );

  runApp(const MyMoonWeb());
}

class MyMoonWeb extends StatelessWidget {
  const MyMoonWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mea Luna',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E0E10),
        primaryColor: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: const WebMainPage(),
    );
  }
}

class WebMainPage extends StatefulWidget {
  const WebMainPage({super.key});

  @override
  State<WebMainPage> createState() => _WebMainPageState();
}

class _WebMainPageState extends State<WebMainPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isOverlayActive = false;

  final _headerKey = GlobalKey();
  final _calendarKey = GlobalKey();
  final _myMoonKey = GlobalKey();
  final _orbitKey = GlobalKey();
  final _knowledgeKey = GlobalKey();
  final _boardKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _setOverlayActive(bool value) {
    setState(() => _isOverlayActive = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      key: _headerKey,
                      child: const HeaderSection(),
                    ),
                    const Divider(color: Colors.white12),

                    Container(
                      key: _calendarKey,
                      child: const CalendarSection(),
                    ),
                    const Divider(color: Colors.white12),

                    Container(
                      key: _myMoonKey,
                      child: MyMoonSection(onOverlayChanged: _setOverlayActive),
                    ),
                    const Divider(color: Colors.white12),

                    Visibility(
                      visible: !_isOverlayActive,
                      maintainState: true,
                      child: Container(
                        key: _orbitKey,
                        child: const OrbitSection(),
                      ),
                    ),

                    const Divider(color: Colors.white12),
                    Container(
                      key: _knowledgeKey,
                      child: const KnowledgeSection(),
                    ),
                    const Divider(color: Colors.white12),

                    Container(
                      key: _boardKey,
                      child: const BoardSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 20,
            top: MediaQuery
                .of(context)
                .size
                .height / 3,
            child: _NavBar(
              onHeader: () => _scrollTo(_headerKey),
              onCalendar: () => _scrollTo(_calendarKey),
              onMyMoon: () => _scrollTo(_myMoonKey),
              onOrbit: () => _scrollTo(_orbitKey),
              onKnowledge: () => _scrollTo(_knowledgeKey),
              onBoard: () => _scrollTo(_boardKey),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatefulWidget {
  final VoidCallback onHeader;
  final VoidCallback onCalendar;
  final VoidCallback onMyMoon;
  final VoidCallback onOrbit;
  final VoidCallback onKnowledge;
  final VoidCallback onBoard;

  const _NavBar({
    required this.onHeader,
    required this.onCalendar,
    required this.onMyMoon,
    required this.onOrbit,
    required this.onKnowledge,
    required this.onBoard,
  });

  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> {
  int _hoverIndex = -1;

  final _icons = const [
    Icons.home,
    Icons.calendar_month,
    Icons.nightlight,
    Icons.public,
    Icons.lightbulb,
    Icons.forum,
    Icons.settings, // ⭐ 관리자용 아이콘 추가
  ];

  final _titles = const [
    '오늘의 달',
    '달의 달력',
    '나의 달 찾기',
    '공전 궤도',
    '달에 관하여',
    '당신의 달 이야기',
    '관리자 모드', // ⭐ 추가
  ];

  @override
  Widget build(BuildContext context) {
    // 1. 기존의 콜백 리스트입니다. (0번~5번 인덱스)
    final callbacks = [
      widget.onHeader,
      widget.onCalendar,
      widget.onMyMoon,
      widget.onOrbit,
      widget.onKnowledge,
      widget.onBoard,
    ];

    return Column(
      children: List.generate(_icons.length, (i) {
        final isHover = _hoverIndex == i;

        return Tooltip(
          message: _titles[i],
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(6),
          ),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoverIndex = i),
            onExit: (_) => setState(() => _hoverIndex = -1),
            child: GestureDetector(
              // ⭐ 이 부분을 수정합니다!
              onTap: () {
                if (i == 6) {
                  // 6번(마지막 설정 아이콘)을 누르면 관리자 페이지로 이동합니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                } else {
                  // 0~5번까지는 원래대로 해당 섹션으로 스크롤 이동합니다.
                  callbacks[i]();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHover ? Colors.amberAccent : Colors.white24,
                ),
                child: Icon(
                  _icons[i],
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
