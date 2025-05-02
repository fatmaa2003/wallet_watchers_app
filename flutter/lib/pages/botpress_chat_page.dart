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
  String? _chatUrl;

  @override
  void initState() {
    super.initState();
    _loadChatUrl();
  }

  Future<void> _loadChatUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final webChatUserId = prefs.getString('webChatUserId') ?? 'guest';

    print('WebChat userId: $webChatUserId');

    const baseBotpressUrl =
        'https://cdn.botpress.cloud/webchat/v2.4/shareable.html?configUrl=https://files.bpcontent.cloud/2025/04/28/16/20250428162136-6JLCM7ZL.json';

    final url = '$baseBotpressUrl'
        '&userId=$webChatUserId'
        '&sessionId=$webChatUserId'
        '&clearHistory=true';

    print('Loading Botpress URL: $url');

    _controller = WebViewController()
      ..clearCache() // ✅ Clear session
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    setState(() {
      _chatUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Chat Assistant')),
      body: _chatUrl == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
