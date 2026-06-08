import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  // ⭐ 수정 모드일 때 기존 데이터를 넘겨받기 위한 변수 추가
  final String? docId;
  final Map<String, dynamic>? initialData;

  const AdminPage({super.key, this.docId, this.initialData});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late TextEditingController _titleController;
  late TextEditingController _orderController;
  late TextEditingController _thumbController;
  List<Map<String, dynamic>> _contentList = [];

  @override
  void initState() {
    super.initState();
    // ⭐ 기존 데이터가 있으면 채워넣고, 없으면 비워둡니다.
    _titleController =
        TextEditingController(text: widget.initialData?['title'] ?? '');
    _orderController = TextEditingController(
        text: widget.initialData?['order']?.toString() ?? '');
    _thumbController =
        TextEditingController(text: widget.initialData?['thumbnail'] ?? '');
    _contentList =
    List<Map<String, dynamic>>.from(widget.initialData?['contentList'] ?? []);
  }

  void _addText() =>
      setState(() => _contentList.add({"type": "text", "value": ""}));

  void _addImage() =>
      setState(() =>
      _contentList.add(
      {"type": "image", "value": "assets/knowledge_images/"}));

  void _saveToFirebase() async {
    final data = {
      'title': _titleController.text,
      'order': int.tryParse(_orderController.text) ?? 0,
      'thumbnail': _thumbController.text,
      'contentList': _contentList,
    };

    try {
      if (widget.docId != null) {
        // ⭐ 기존 글 수정 (Update)
        await FirebaseFirestore.instance.collection('knowledge').doc(
            widget.docId).update(data);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('글이 수정되었습니다!')));
      } else {
        // ⭐ 새 글 등록 (Add)
        await FirebaseFirestore.instance.collection('knowledge').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('새 글이 발행되었습니다!')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('에러 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E10),
      appBar: AppBar(
        title: Text(widget.docId != null ? '달 이야기 수정하기' : '새로운 달 이야기 쓰기'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInput("글 제목", _titleController),
            _buildInput("노출 순서 (숫자)", _orderController),
            _buildInput("썸네일 이미지 경로", _thumbController),
            const Divider(color: Colors.white24, height: 40),

            ..._contentList
                .asMap()
                .entries
                .map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                        item['type'] == 'text' ? Icons.short_text : Icons.image,
                        color: Colors.white70),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        // ⭐ 행갈이 가능하게 수정
                        keyboardType: TextInputType.multiline,
                        // ⭐ 행갈이 가능하게 수정
                        controller: TextEditingController(text: item['value'])
                          ..selection = TextSelection.collapsed(
                              offset: item['value'].length),
                        decoration: InputDecoration(
                          labelText: item['type'] == 'text'
                              ? '본문 내용 입력'
                              : '이미지 파일명 입력',
                          labelStyle: const TextStyle(color: Colors.white38),
                        ),
                        onChanged: (val) => _contentList[idx]['value'] = val,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          setState(() => _contentList.removeAt(idx)),
                    )
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(onPressed: _addText,
                    icon: const Icon(Icons.add_comment),
                    label: const Text("텍스트 추가")),
                const SizedBox(width: 15),
                ElevatedButton.icon(onPressed: _addImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("이미지 추가")),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.docId != null
                    ? Colors.blueAccent
                    : Colors.amberAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
              ),
              onPressed: _saveToFirebase,
              child: Text(widget.docId != null ? "수정 완료하기" : "파이어베이스에 발행하기",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white70)),
    );
  }
}