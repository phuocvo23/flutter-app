import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

/// Service để quản lý products trong Firestore
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Lấy tất cả products
  Stream<List<Product>> getAll() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy products nổi bật
  Stream<List<Product>> getFeatured() {
    return _firestore
        .collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy products mới
  Stream<List<Product>> getNewArrivals() {
    return _firestore
        .collection(_collection)
        .where('isNew', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy products theo category
  Stream<List<Product>> getByCategory(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: categoryId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy product theo ID
  Future<Product?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm product mới
  Future<void> add(Product product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id)
        .set(product.toFirestore());
  }

  /// Cập nhật product
  Future<void> update(Product product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id)
        .update(product.toFirestore());
  }

  /// Xóa product
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
