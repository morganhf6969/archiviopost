import '../database/saved_item_dao.dart';
import '../models/saved_item.dart';

class SavedItemRepository {
  final SavedItemDao _dao = SavedItemDao();

  // =========================
  // CRUD BASE
  // =========================

  Future<void> save(SavedItem item) {
    return _dao.insert(item);
  }

  Future<List<SavedItem>> getAll() {
    return _dao.getAll();
  }

  Future<List<SavedItem>> getByCategory(String category) {
    return _dao.getByCategory(category);
  }

  Future<List<SavedItem>> getUncategorized() {
    return _dao.getUncategorized();
  }

  Future<void> delete(int id) {
    return _dao.delete(id);
  }

  // =========================
  // CONTATORI
  // =========================

  Future<int> countByCategory(String category) {
    return _dao.countByCategory(category);
  }
}
