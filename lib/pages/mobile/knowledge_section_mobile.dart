import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_page.dart'; // 수정 기능을 위해 필요

class KnowledgeSectionMobile extends StatefulWidget {
  const KnowledgeSectionMobile({super.key});

  @override
  State<KnowledgeSectionMobile> createState() => _KnowledgeSectionMobileState();
}

class _KnowledgeSectionMobileState extends State<KnowledgeSectionMobile> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the Moon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('knowledge')
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text(
                  "에러 발생", style: TextStyle(color: Colors.white));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                // ⭐ 모바일은 2열(또는 1열)로 배치
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85, // 제목 영역을 고려해 약간 길게
                ),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Stack(
                    children: [
                      _MobileHoverCard(
                        title: data['title'] ?? '',
                        imagePath: data['thumbnail'] ?? '',
                        onTap: () {
                          _currentIndex = index;
                          _showPopup(context, docs);
                        },
                      ),
                      // ⭐ 관리자 수정 버튼 (모바일에서도 유지)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 14,
                          child: IconButton(
                            icon: const Icon(
                                Icons.edit, size: 14, color: Colors.white),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    AdminPage(
                                    docId: docs[index].id,
                                    initialData: data),
                              ));
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
  }

  void _showPopup(BuildContext context, List<QueryDocumentSnapshot> docs) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentDoc = docs[_currentIndex].data() as Map<String,
                dynamic>;
            final contentList = currentDoc['contentList'] as List<dynamic>? ??
                [];

            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
                title: Text(currentDoc['title'] ?? '',
                    style: const TextStyle(fontSize: 16)),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildStoryContent(contentList),
                    ),
                  ),
                  // 하단 네비게이션
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _currentIndex > 0 ? () =>
                              setState(() => _currentIndex--) : null,
                          icon: const Icon(
                              Icons.arrow_back_ios, color: Colors.white),
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          onPressed: _currentIndex < docs.length - 1 ? () =>
                              setState(() => _currentIndex++) : null,
                          icon: const Icon(
                              Icons.arrow_forward_ios, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStoryContent(List<dynamic> contentList) {
    return Column(
      children: contentList.map((item) {
        if (item['type'] == 'image') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(item['value'] ?? '', fit: BoxFit.contain),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              item['value'] ?? '',
              style: const TextStyle(
                  color: Colors.white70, height: 1.6, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          );
        }
      }).toList(),
    );
  }
}

class _MobileHoverCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _MobileHoverCard(
      {required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                  imagePath, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}