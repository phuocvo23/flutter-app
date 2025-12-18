import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hero_banner.dart';

/// Service để quản lý Hero Banners trong Firestore
class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'banners';

  /// Lấy tất cả banners (sắp xếp theo order)
  Stream<List<HeroBanner>> getAll() {
    return _firestore
        .collection(_collection)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => HeroBanner.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Lấy banners active để hiển thị trên app (filter client-side to avoid index)
  Stream<List<HeroBanner>> getActiveBanners() {
    return _firestore
        .collection(_collection)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => HeroBanner.fromFirestore(doc))
                  .where((banner) => banner.isActive)
                  .toList(),
        );
  }

  /// Lấy banner theo ID
  Future<HeroBanner?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return HeroBanner.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm banner mới
  Future<String> add(HeroBanner banner) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(banner.toFirestore());
    return docRef.id;
  }

  /// Cập nhật banner
  Future<void> update(HeroBanner banner) async {
    await _firestore
        .collection(_collection)
        .doc(banner.id)
        .update(banner.toFirestore());
  }

  /// Xóa banner
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Cập nhật thứ tự (reorder)
  Future<void> updateOrder(String id, int newOrder) async {
    await _firestore.collection(_collection).doc(id).update({
      'order': newOrder,
    });
  }

  /// Toggle active/inactive
  Future<void> toggleActive(String id, bool isActive) async {
    await _firestore.collection(_collection).doc(id).update({
      'isActive': isActive,
    });
  }
}
