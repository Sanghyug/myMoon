import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OrbitSection extends StatefulWidget {
  const OrbitSection({super.key});

  @override
  State<OrbitSection> createState() => _OrbitSectionState();
}

class _OrbitSectionState extends State<OrbitSection> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('web_assets/orbit3d_horizons.html');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: WebViewWidget(controller: _controller),
    );
  }
}
