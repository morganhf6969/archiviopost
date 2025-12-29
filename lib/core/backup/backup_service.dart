import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/saved_item.dart';
import '../../data/repositories/saved_item_repository.dart';

class BackupService {
  static final SavedItemRepository _repo = SavedItemRepository();

  /// =========================
  /// EXPORT BACKUP (JSON)
  /// =========================
  static Future<File> exportJson() async {
    final items = await _repo.getAll();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'items': items.map(_itemToJson).toList(),
    };

    final jsonString =
        const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'archiviopost_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');

    return file.writeAsString(jsonString);
  }

  /// =========================
  /// IMPORT BACKUP (JSON)
  /// =========================
  static Future<int> importJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return 0;
    }

    final file = File(result.files.single.path!);
    final content = await file.readAsString();

    final decoded = json.decode(content);

    // 🔁 Supporto sia backup nuovi che vecchi
    final List<dynamic> items =
        decoded is Map<String, dynamic>
            ? (decoded['items'] ?? [])
            : decoded as List<dynamic>;

    int imported = 0;

    for (final raw in items) {
      try {
        final item = SavedItem(
          url: raw['url'],
          platform: raw['platform'],
          category: raw['category'] ?? 'Altro',
          hashtags: List<String>.from(raw['hashtags'] ?? []),
          createdAt: DateTime.parse(raw['createdAt']),
        );

        await _repo.save(item);
        imported++;
      } catch (_) {
        // ignora elementi non validi
      }
    }

    return imported;
  }

  /// =========================
  /// SERIALIZZAZIONE
  /// =========================
  static Map<String, dynamic> _itemToJson(SavedItem item) {
    return {
      'url': item.url,
      'platform': item.platform,
      'category': item.category,
      'hashtags': item.hashtags,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }
}
