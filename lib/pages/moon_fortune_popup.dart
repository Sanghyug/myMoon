import 'package:flutter/material.dart';

class MoonFortunePopup extends StatefulWidget {
  final String fortuneText;

  const MoonFortunePopup({super.key, required this.fortuneText});

  @override
  State<MoonFortunePopup> createState() => _MoonFortunePopupState();
}

class _MoonFortunePopupState extends State<MoonFortunePopup> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _showFortune();
  }

  Future<void> _showFortune() async {
    // 광고 넣을 자리 (현재는 타이머만)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      child: Container(
        padding: const EdgeInsets.all(24),
        height: 400,
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : Column(
          children: [
            const Text(
              "오늘의 운세",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.fortuneText,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "닫기",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
