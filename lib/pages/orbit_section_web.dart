// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; //
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui; // ⭐ 'dart:ui_web'을 'ui'라는 이름으로 가져옵니다
import 'package:flutter/material.dart'; //

class OrbitSection extends StatefulWidget {
  const OrbitSection({super.key});

  @override
  State<OrbitSection> createState() => _OrbitSectionState();
}

class _OrbitSectionState extends State<OrbitSection> {
  @override
  void initState() {
    super.initState();

    ui.platformViewRegistry.registerViewFactory(
      'orbit-iframe',
          (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'assets/web_assets/orbit3d_horizons.html'
          ..style.border = 'none'
          ..width = '100%'
          ..height = '520';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 520,
      child: HtmlElementView(viewType: 'orbit-iframe'),
    );
  }
}
