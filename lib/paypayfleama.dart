import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Paypayfleama extends StatefulWidget {
  final ValueNotifier<String> searchQueryNotifier;

  const Paypayfleama({super.key, required this.searchQueryNotifier});

  @override
  State<Paypayfleama> createState() => _PaypayfleamaState();
}

class _PaypayfleamaState extends State<Paypayfleama> {
  late final WebViewController _controller;
  // String _title = ""; // UI上で使用されていないため削除
  @override
  void initState() {
    super.initState();
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('Page finished loading (PayPay Flea Market): $url');
            // _title = await controller.runJavaScriptReturningResult('document.title;') as String; // UI上で使用されていないため削除
            // debugPrint(_title); // UI上で使用されていないため削除
            //debugPrint(await controller.runJavaScriptReturningResult('document.documentElement.scrollHeight;') as String);
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..setUserAgent(
          "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/118.0.0.0")
      // 初期ロードは _loadPageWithQuery で行う
      ;

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
    _controller = controller;

    // ValueNotifierのリスナーを設定
    widget.searchQueryNotifier.addListener(_onSearchQueryChanged);
    // 初期ページの読み込み
    _loadPageWithQuery(widget.searchQueryNotifier.value);
  }

  void _onSearchQueryChanged() {
    _loadPageWithQuery(widget.searchQueryNotifier.value);
  }

  void _loadPageWithQuery(String query) {
    String url;
    if (query.isNotEmpty) {
      url = 'https://paypayfleamarket.yahoo.co.jp/search/${Uri.encodeComponent(query)}';
    } else {
      url = "https://paypayfleamarket.yahoo.co.jp/";
    }
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    // Scaffoldは不要。MyHomePageのPreloadPageView内で使用されるため。
    return Column( // 必要に応じてこのColumnも削除可能
      children: [
        Expanded(
          child: WebViewWidget(controller: _controller),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.searchQueryNotifier.removeListener(_onSearchQueryChanged);
    super.dispose();
  }
}
