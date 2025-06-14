import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final ValueNotifier<String> searchQueryNotifier;

  const Search({super.key, required this.searchQueryNotifier});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  // ListViewに表示するサンプルデータ
  List<String> _items = List.generate(30, (index) => 'アイテム ${index + 1}');
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _items; // 初期状態では全てのアイテムを表示
  }

  void _performSearch(String query) {
    widget.searchQueryNotifier.value = query; // Notifierに値をセット
    if (query.isEmpty) {
      setState(() {
        _filteredItems = _items;
      });
    } else {
      setState(() {
        _filteredItems = _items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScaffoldとAppBarは削除。MyHomePageのAppBarを共通で使用するため。
    return Padding(
      padding: const EdgeInsets.all(16.0), // ルートウィジェットとしてPaddingを使用
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '検索キーワードを入力...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  _performSearch(_searchController.text);
                },
                child: const Text('検索'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredItems[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}