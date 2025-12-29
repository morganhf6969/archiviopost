import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/share_service.dart';
import '../../data/repositories/saved_item_repository.dart';
import '../categorize/categorize_page.dart';
import '../list/category_list_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SavedItemRepository _repo = SavedItemRepository();

  StreamSubscription<String>? _shareSub;
  bool _handlingShare = false;

  final List<_HomeTile> _tiles = const [
    _HomeTile(
      'Cerca',
      Icons.search,
      Colors.grey,
      isSearch: true,
    ),
    _HomeTile('Cucina', Icons.restaurant, Colors.orange),
    _HomeTile('Tecnologia', Icons.computer, Colors.blue),
    _HomeTile('Arte', Icons.palette, Colors.purple),
    _HomeTile('Musica', Icons.music_note, Colors.green),
    _HomeTile('Divertente', Icons.emoji_emotions, Colors.red),
    _HomeTile('Altro', Icons.more_horiz, Colors.blueGrey),
  ];

  @override
  void initState() {
    super.initState();

    _shareSub = ShareService.linkStream.listen((link) async {
      if (!mounted || _handlingShare) return;
      _handlingShare = true;

      await _openCategorizePage(link: link);

      _handlingShare = false;
    });
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  Future<void> _openCategorizePage({String? link}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategorizePage(link: link),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.layers_outlined, size: 26),
        ),
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            tooltip: 'Impostazioni',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Aggiungi link',
        child: const Icon(Icons.add),
        onPressed: () => _openCategorizePage(),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: 16,
        ),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 3,
            mainAxisSpacing: isMobile ? 12 : 20,
            crossAxisSpacing: isMobile ? 12 : 20,
            childAspectRatio: isMobile ? 1.15 : 1.1,
          ),
          itemBuilder: (context, index) {
            return _buildTile(context, _tiles[index], isMobile);
          },
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    _HomeTile tile,
    bool isMobile,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (tile.isSearch) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SearchPage(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryListPage(
                category: tile.label,
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: tile.isSearch ? 3 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tile.icon,
                size: isMobile ? 34 : 42,
                color: tile.color,
              ),
              const SizedBox(height: 12),
              Text(
                tile.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (!tile.isSearch) ...[
                const SizedBox(height: 6),
                FutureBuilder<int>(
                  future: _repo.countByCategory(tile.label),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == 0) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${snapshot.data} link',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTile {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSearch;

  const _HomeTile(
    this.label,
    this.icon,
    this.color, {
    this.isSearch = false,
  });
}
