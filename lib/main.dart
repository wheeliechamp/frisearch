import 'package:flutter/material.dart';
import 'package:myapp/search.dart';
import 'package:myapp/mercari.dart';
import 'package:myapp/paypayfleama.dart';
import 'package:preload_page_view/preload_page_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriSearch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'フリマ横断検索'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title), // widget.title を使用
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Expanded(
          child: PreloadPageView(
            preloadPagesCount: 3,
            controller: PreloadPageController(initialPage: 0),
            onPageChanged: (int position) {
              debugPrint('page changed current: $position');
            },
            children: [
              Search(searchQueryNotifier: _searchQueryNotifier),
              Mercari(searchQueryNotifier: _searchQueryNotifier),
              Paypayfleama(searchQueryNotifier: _searchQueryNotifier),
            ],
          ))
          // TextFormField(),
      ],)
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //     ],
      //   ),
      // ),
    );
  }

  @override
  void dispose() {
    _searchQueryNotifier.dispose();
    super.dispose();
  }
}
