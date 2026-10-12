import 'package:flutter/material.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({
    super.key,
    required this.title,
    required this.asset,
  });

  final String title;
  final String asset;

  static Future<void> open(
    BuildContext context, {
    required String title,
    required String asset,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalPage(title: title, asset: asset),
      ),
    );
  }

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  late final WebViewController controller;
  var loading = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(Pocket.bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => loading = p);
          },
        ),
      )
      ..loadFlutterAsset(widget.asset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pocket.bg,
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (loading < 100)
            LinearProgressIndicator(
              value: loading == 0 ? null : loading / 100,
              color: Pocket.sky,
              backgroundColor: Pocket.stroke,
              minHeight: 2,
            ),
          Expanded(child: WebViewWidget(controller: controller)),
        ],
      ),
    );
  }
}
