import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static final List<_CategoryItem> categories = [
    _CategoryItem('Cucina', Icons.restaurant, Colors.orange),
    _CategoryItem('Tecnologia', Icons.computer, Colors.blue),
    _CategoryItem('Arte', Icons.palette, Colors.purple),
    _CategoryItem('Musica', Icons.music_note, Colors.green),
    _CategoryItem('Divertente', Icons.emoji_emotions, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = categories[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: apri lista contenuti per categoria
          },
          child: Container(
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 32, color: item.color),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  final Color color;

  _CategoryItem(this.label, this.icon, this.color);
}
