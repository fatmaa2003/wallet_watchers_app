import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BotpressChatPage extends StatefulWidget {
  const BotpressChatPage({super.key});

  @override
  State<BotpressChatPage> createState() => _BotpressChatPageState();
}

class _BotpressChatPageState extends State<BotpressChatPage> {
  late WebViewController _controller;
  String? webChatUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? 'guest';
      final externalId = 'wallet_user_$userId';

      final configUrl = 'https://files.bpcontent.cloud/2025/04/28/16/20250428162136-6JLCM7ZL.json';

      setState(() {
        webChatUrl = 'https://cdn.botpress.cloud/webchat/v2.5/shareable.html'
            '?configUrl=$configUrl&externalId=$externalId';
        _isLoading = false;
      });

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onWebResourceError: (error) => setState(() {
            _error = 'Failed to load chat: \${error.description}';
            _isLoading = false;
          }),
        ))
        ..loadRequest(Uri.parse(webChatUrl!));

    } catch (e) {
      setState(() {
        _error = 'Initialization error: \${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            ElevatedButton(
              onPressed: _initWebView,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isLoading || webChatUrl == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const LinearProgressIndicator(),
      ],
    );
  }
}
