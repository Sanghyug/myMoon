import 'package:flutter/material.dart';

class OrbitSection extends StatelessWidget {
  const OrbitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 520,
      child: Center(
        child: Text(
          "Orbit view is not supported on this platform.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
