import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoardSectionMobile extends StatefulWidget {
  const BoardSectionMobile({super.key});

  @override
  State<BoardSectionMobile> createState() => _BoardSectionMobileState();
}

class _BoardSectionMobileState extends State<BoardSectionMobile> {
  final TextEditingController _commentController = TextEditingController();

  void _addComment() async {
    if (_commentController.text
        .trim()
        .isEmpty) return;
    await FirebaseFirestore.instance.collection('comments').add({
      'name': '달 여행자',
      'comment': _commentController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신의 달 이야기', style: TextStyle(fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent)),
          const SizedBox(height: 12),
          const Text('달에 대한 추억을 나눠보세요.',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 24),

          // 입력창
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '이야기 남기기...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.amberAccent),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addComment,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black),
                child: const Text('등록'),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.white12),

          // 실시간 리스트
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('comments').orderBy(
                'createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person_outline, color: Colors.white38,
                            size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['name'] ?? '익명', style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(data['comment'] ?? '',
                                  style: const TextStyle(color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}