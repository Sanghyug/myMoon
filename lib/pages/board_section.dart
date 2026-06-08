import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ⭐ Firebase 추가

class BoardSection extends StatefulWidget {
  const BoardSection({super.key});

  @override
  State<BoardSection> createState() => _BoardSectionState();
}

class _BoardSectionState extends State<BoardSection> {
  final TextEditingController _commentController = TextEditingController();

  // 📝 글 등록 함수
  void _addComment() async {
    if (_commentController.text
        .trim()
        .isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('comments').add({
        'name': '익명의 달 여행자', // 나중에 로그인 기능을 넣으면 이름을 바꿀 수 있어요.
        'comment': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // ⭐ 등록 시간 저장
      });
      _commentController.clear(); // 입력창 비우기
      FocusScope.of(context).unfocus(); // 키보드 내리기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('글 등록 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '당신의 달 이야기',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '달에 대한 추억, 생각, 경험을 나눠보세요.',
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 30),

          // 📩 댓글 입력창
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController, // ⭐ 컨트롤러 연결
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '당신의 이야기를 남겨보세요...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.amberAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (_) => _addComment(), // 엔터 쳐도 등록되게
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addComment, // ⭐ 함수 연결
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 15),
                ),
                child: const Text(
                    '등록', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 40),
          const Divider(color: Colors.white12),

          // 💬 실시간 글 목록
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('comments')
                .orderBy('createdAt', descending: true) // ⭐ 최신글이 위로 오게
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text(
                  '데이터를 불러올 수 없습니다.', style: TextStyle(color: Colors.white54));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Colors.amberAccent),
                ));
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('아직 이야기가 없어요. 첫 번째 이야기를 남겨보세요!',
                      style: TextStyle(color: Colors.white30))),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _commentTile(
                    data['name'] ?? '익명',
                    data['comment'] ?? '',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _commentTile(String name, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person, color: Colors.white38, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(comment,
                    style: const TextStyle(
                        color: Colors.white70, height: 1.4, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}