import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/saved_item.dart';
import '../../data/repositories/saved_item_repository.dart';

class CategoryListPage extends StatelessWidget {
  final String category;

  const CategoryListPage({
    super.key,
    required this.category,
  });

  bool get _isAltro => category.toLowerCase() == 'altro';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CategoryListViewModel>(
      create: (_) => CategoryListViewModel(category)..load(),
      child: Consumer<CategoryListViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(category),
            ),
            body: _buildBody(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CategoryListViewModel vm) {
    if (vm.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (vm.items.isEmpty) {
      return Center(
        child: Text(
          _isAltro
              ? 'Nessun contenuto non categorizzato'
              : 'Nessun contenuto in questa categoria',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: vm.items.length,
      itemBuilder: (context, index) {
        final item = vm.items[index];

        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),

          // 🔴 CONFERMA ELIMINAZIONE
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Eliminare contenuto?'),
                content: const Text(
                  'Vuoi eliminare definitivamente questo link?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Annulla'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Elimina'),
                  ),
                ],
              ),
            );
          },

          // 🗑️ DELETE
          onDismissed: (_) async {
            await vm.delete(item.id!);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Elemento eliminato'),
                ),
              );
            }
          },

          child: Card(
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 8),

                  // 🔖 HASHTAG
                  if (item.hashtags.isNotEmpty)
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
          ),
        );
      },
    );
  }
}

/// ===============================
/// VIEWMODEL
/// ===============================
class CategoryListViewModel extends ChangeNotifier {
  final String category;
  final SavedItemRepository _repo = SavedItemRepository();

  List<SavedItem> items = [];
  bool loading = false;

  CategoryListViewModel(this.category);

  Future<void> load() async {
    loading = true;
    notifyListeners();

    if (category.toLowerCase() == 'altro') {
      items = await _repo.getUncategorized();
    } else {
      items = await _repo.getByCategory(category);
    }

    loading = false;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
