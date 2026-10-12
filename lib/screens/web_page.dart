import 'package:flutter/material.dart';
import 'package:pocket_calculator/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key, required this.url});

  final String url;

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController controller;
  var loading = 0;
  var canGoBack = false;
  var canGoForward = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Pocket.bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => loading = p);
          },
          onPageFinished: (_) => _refreshNav(),
          onPageStarted: (_) => _refreshNav(),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _refreshNav() async {
    final back = await controller.canGoBack();
    final forward = await controller.canGoForward();
    if (!mounted) return;
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = loading < 100;
    return Scaffold(
      backgroundColor: Pocket.bg,
      body: SafeArea(
        child: Column(
          children: [
            Material(
              color: Pocket.surface,
              child: Row(
                children: [
                  _NavButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    enabled: canGoBack,
                    onPressed: () async {
                      await controller.goBack();
                      await _refreshNav();
                    },
                  ),
                  _NavButton(
                    icon: Icons.arrow_forward_rounded,
                    tooltip: 'Forward',
                    enabled: canGoForward,
                    onPressed: () async {
                      await controller.goForward();
                      await _refreshNav();
                    },
                  ),
                  _NavButton(
                    icon: busy ? Icons.close_rounded : Icons.refresh_rounded,
                    tooltip: busy ? 'Stop' : 'Reload',
                    enabled: true,
                    onPressed: () {
                      if (busy) {
                        controller.runJavaScript('window.stop()');
                      } else {
                        controller.reload();
                      }
                    },
                  ),
                  _NavButton(
                    icon: Icons.home_rounded,
                    tooltip: 'Home',
                    enabled: true,
                    onPressed: () =>
                        controller.loadRequest(Uri.parse(widget.url)),
                  ),
                ],
              ),
            ),
            if (busy)
              LinearProgressIndicator(
                value: loading == 0 ? null : loading / 100,
                color: Pocket.sky,
                backgroundColor: Pocket.stroke,
                minHeight: 2,
              ),
            Expanded(child: WebViewWidget(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      color: Pocket.text,
      disabledColor: Pocket.muted.withValues(alpha: 0.4),
    );
  }
}
