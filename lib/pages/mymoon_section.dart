// lib/pages/mymoon_section.dart

import 'package:flutter/material.dart';
import 'voice_of_moon_section.dart';

class MyMoonSection extends StatelessWidget {
  final ValueChanged<bool>? onOverlayChanged;

  const MyMoonSection({
    super.key,
    this.onOverlayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // ← const 빼는 게 헷갈림 줄이기 좋아
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: VoiceOfMoonSection(),
      ),
    );
  }
}
