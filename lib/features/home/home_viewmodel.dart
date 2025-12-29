import 'package:flutter/foundation.dart';
import '../../data/models/saved_item.dart';
import '../../data/repositories/saved_item_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final SavedItemRepository _repo = SavedItemRepository();

  List<SavedItem> _items = [];
  List<SavedItem> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _items = await _repo.getAll();

    _loading = false;
    notifyListeners();
  }
}
