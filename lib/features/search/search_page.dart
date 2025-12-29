import 'package:flutter/material.dart';

import '../../data/models/saved_item.dart';
import '../../data/repositories/saved_item_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SavedItemRepository _repo = SavedItemRepository();
  final TextEditingController _controller = TextEditingController();

  List<SavedItem> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    final all = await _repo.getAll();

    setState(() {
      _results = all
          .where(
            (item) => item.hashtags.any(
              (h) => h.toLowerCase().contains(q),
            ),
          )
          .toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerca'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            // 🔍 SEARCH BAR
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Cerca per hashtag (es. ricetta)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ⏳ LOADING
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

            // 💤 NESSUNA RICERCA
            else if (_controller.text.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Inizia a digitare per cercare',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )

            // ❌ NESSUN RISULTATO
            else if (_results.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Nessun risultato',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )

            // 📋 RISULTATI
            else
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔗 URL
                            Text(
                              item.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium,
                            ),

                            const SizedBox(height: 8),

                            // 🔖 HASHTAG
                            Wrap(
                              spacing: 6,
                              runSpacing: -6,
                              children: item.hashtags
                                  .map(
                                    (h) => Chip(
                                      label: Text('#$h'),
                                      visualDensity:
                                          VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
