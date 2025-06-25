import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Mercari extends StatefulWidget {
  final ValueNotifier<String> searchQueryNotifier;

  const Mercari({super.key, required this.searchQueryNotifier});

  @override
  State<Mercari> createState() => _MercariState();
}

class _MercariState extends State<Mercari> {
  late final WebViewController _controller;
  // String _title = ""; // UI上で使用されていないためコメントアウトまたは削除
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
            debugPrint('Page finished loading: $url');
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
      ..setUserAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.62 Safari/537.36")
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
      url = 'https://jp.mercari.com/search?keyword=${Uri.encodeComponent(query)}';
    } else {
      debugPrint('Mercari: Loading default URL because query is empty.');
      url = "https://jp.mercari.com/";
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
        // TextFormField(), // 目的が不明なためコメントアウト
      ],
    );
  }

  @override
  void dispose() {
    widget.searchQueryNotifier.removeListener(_onSearchQueryChanged);
    // _controllerのdisposeはWebViewWidgetが行うため、通常は不要
    super.dispose();
  }
}
