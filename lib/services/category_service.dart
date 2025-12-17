import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

/// Service để quản lý categories trong Firestore
class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  /// Lấy tất cả categories
  Stream<List<Category>> getAll() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy category theo ID
  Future<Category?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Category.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm category mới
  Future<void> add(Category category) async {
    await _firestore
        .collection(_collection)
        .doc(category.id)
        .set(category.toFirestore());
  }

  /// Cập nhật category
  Future<void> update(Category category) async {
    await _firestore
        .collection(_collection)
        .doc(category.id)
        .update(category.toFirestore());
  }

  /// Xóa category
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
