import 'package:flutter/material.dart';

import '../../data/models/saved_item.dart';
import '../../data/repositories/saved_item_repository.dart';

class CategorizePage extends StatefulWidget {
  final String? link;

  const CategorizePage({
    super.key,
    this.link,
  });

  @override
  State<CategorizePage> createState() => _CategorizePageState();
}

class _CategorizePageState extends State<CategorizePage> {
  final SavedItemRepository _repo = SavedItemRepository();

  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _linkFocus = FocusNode();

  String? _selectedCategory;
  final List<String> _hashtags = [];
  bool _saving = false;

  final List<_Category> _categories = const [
    _Category('Cucina', Icons.restaurant, Colors.orange),
    _Category('Tecnologia', Icons.computer, Colors.blue),
    _Category('Arte', Icons.palette, Colors.purple),
    _Category('Musica', Icons.music_note, Colors.green),
    _Category('Divertente', Icons.emoji_emotions, Colors.red),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.link != null && widget.link!.trim().isNotEmpty) {
      _linkController.text = widget.link!.trim();
    }

    // focus automatico (fondamentale su tablet)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _linkFocus.requestFocus();
      }
    });
  }

  // =========================
  // HASHTAG
  // =========================
  void _addHashtag() {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) return;

    final tag = raw.startsWith('#') ? raw.substring(1) : raw;

    if (!_hashtags.contains(tag)) {
      setState(() => _hashtags.add(tag));
    }

    _tagController.clear();
  }

  // =========================
  // SAVE
  // =========================
  Future<void> _save() async {
    if (_saving) return;

    final link = _linkController.text.trim();

    if (link.isEmpty) {
      _showSnack('Inserisci un link valido');
      return;
    }

    if (_selectedCategory == null) {
      _showSnack('Seleziona una categoria');
      return;
    }

    setState(() => _saving = true);

    final item = SavedItem(
      url: link,
      platform: _detectPlatform(link),
      category: _selectedCategory!,
      hashtags: List.from(_hashtags),
      createdAt: DateTime.now(),
    );

    try {
      await _repo.save(item);

      if (!mounted) return;

      _showSnack('Contenuto salvato');
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Errore nel salvataggio');
      setState(() => _saving = false);
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _detectPlatform(String url) {
    if (url.contains('instagram')) return 'instagram';
    if (url.contains('tiktok')) return 'tiktok';
    if (url.contains('facebook')) return 'facebook';
    return 'altro';
  }

  @override
  void dispose() {
    _linkController.dispose();
    _tagController.dispose();
    _linkFocus.dispose();
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizza'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Link', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            TextField(
              controller: _linkController,
              focusNode: _linkFocus,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'Incolla qui il link',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text('Categoria', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((c) {
                final selected = _selectedCategory == c.label;

                return ChoiceChip(
                  label: Text(c.label),
                  avatar: Icon(c.icon, size: 18),
                  selected: selected,
                  selectedColor: c.color.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() => _selectedCategory = c.label);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            Text('Hashtag', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onSubmitted: (_) => _addHashtag(),
                    decoration: InputDecoration(
                      hintText: '#ricetta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addHashtag,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: -8,
              children: _hashtags
                  .map(
                    (tag) => Chip(
                      label: Text('#$tag'),
                      onDeleted: () {
                        setState(() => _hashtags.remove(tag));
                      },
                    ),
                  )
                  .toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salva', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;

  const _Category(this.label, this.icon, this.color);
}
