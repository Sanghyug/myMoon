import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ⭐ 추가됨
import 'admin_page.dart';

class KnowledgeSection extends StatefulWidget {
  const KnowledgeSection({super.key});

  @override
  State<KnowledgeSection> createState() => _KnowledgeSectionState();
}

class _KnowledgeSectionState extends State<KnowledgeSection> {
  // ⭐ 이제 stories 리스트는 파이어베이스에서 가져오므로 초기값은 비워둡니다.
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            int crossCount = 1;

            if (width >= 1200) {
              crossCount = 4;
            } else if (width >= 900) {
              crossCount = 3;
            } else if (width >= 600) {
              crossCount = 2;
            }

            return Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About the Moon',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ⭐ 하드코딩 대신 StreamBuilder로 파이어베이스 실시간 감시
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('knowledge')
                        .orderBy('order') // 피선생님이 정한 순서대로
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text(
                          "데이터 에러", style: TextStyle(color: Colors.white)));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String,
                              dynamic>;
                          // itemBuilder 내부
                          return Stack(
                            children: [
                              _HoverCard(
                                title: data['title'] ?? '',
                                imagePath: data['thumbnail'] ?? '',
                                onTap: () {
                                  _currentIndex = index;
                                  _showPopup(context, docs);
                                },
                              ),
                              // ⭐ 카드 오른쪽 위에 수정 버튼 추가
                              Positioned(
                                top: 5,
                                right: 5,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 18,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, size: 16,
                                        color: Colors.white),
                                    onPressed: () {
                                      // 수정 페이지(AdminPage)로 기존 데이터를 들고 이동!
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AdminPage(
                                                docId: docs[index].id, // 문서 ID
                                                initialData: data, // 기존 데이터
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 🌕 팝업창 수정
  void _showPopup(BuildContext context, List<QueryDocumentSnapshot> docs) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            // 현재 인덱스에 맞는 데이터를 파이어베이스 문서 리스트에서 가져옵니다.
            final currentDoc = docs[_currentIndex].data() as Map<String,
                dynamic>;
            final contentList = currentDoc['contentList'] as List<dynamic>? ??
                [];

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Material(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0 &&
                          _currentIndex < docs.length - 1) {
                        setState(() => _currentIndex++);
                      } else if (details.primaryVelocity! > 0 &&
                          _currentIndex > 0) {
                        setState(() => _currentIndex--);
                      }
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                      child: SingleChildScrollView(
                        key: ValueKey(_currentIndex),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentDoc['title'] ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // ⭐ 피선생님이 관리자 페이지에서 구성한 contentList를 그립니다.
                            _buildStoryContent(contentList),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _currentIndex > 0
                                      ? () => setState(() => _currentIndex--)
                                      : null,
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      color: Colors.white70),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  onPressed: _currentIndex < docs.length - 1
                                      ? () => setState(() => _currentIndex++)
                                      : null,
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                '닫기',
                                style: TextStyle(
                                    color: Colors.amberAccent, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ⭐ 본문 구성 - Firebase의 contentList 구조를 그대로 반영
  Widget _buildStoryContent(List<dynamic> contentList) {
    return Column(
      children: contentList.map((item) {
        final type = item['type'];
        final value = item['value'] ?? '';

        if (type == 'image') {
          return _storyImage(value);
        } else {
          return _storyText(value);
        }
      }).toList(),
    );
  }

  Widget _storyImage(String path) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                path,
                fit: BoxFit.contain,
                // 혹시 이미지가 없을 때를 대비해 에러 처리를 넣었습니다.
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.white24, size: 50),
              ),
            ),
          ),
        ),
      );

  Widget _storyText(String text) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            height: 1.6,
            fontSize: 15,
          ),
        ),
      );
}

/// 💡 Hover 카드 (기존 코드 유지)
class _HoverCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _HoverCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.image_not_supported)),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _hovering
                      ? Colors.black.withOpacity(0.35)
                      : Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 8),
                  color: Colors.black.withOpacity(0.45),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            blurRadius: 4, color: Colors.black, offset: Offset(
                            0, 1)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}