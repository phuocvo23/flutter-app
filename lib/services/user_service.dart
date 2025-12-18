import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Service để quản lý users trong Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Lấy tất cả users
  Stream<List<AppUser>> getAll() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy users theo status
  Stream<List<AppUser>> getByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy user theo ID
  Future<AppUser?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  /// Lấy user theo email
  Future<AppUser?> getByEmail(String email) async {
    final snapshot =
        await _firestore
            .collection(_collection)
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return AppUser.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  /// Thêm user mới
  Future<void> add(AppUser user) async {
    await _firestore
        .collection(_collection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  /// Cập nhật user
  Future<void> update(AppUser user) async {
    await _firestore
        .collection(_collection)
        .doc(user.id)
        .update(user.toFirestore());
  }

  /// Cập nhật status
  Future<void> updateStatus(String userId, String status) async {
    await _firestore.collection(_collection).doc(userId).update({
      'status': status,
    });
  }

  /// Cập nhật order stats cho user
  Future<void> updateOrderStats(String userId, double orderAmount) async {
    await _firestore.collection(_collection).doc(userId).update({
      'totalOrders': FieldValue.increment(1),
      'totalSpent': FieldValue.increment(orderAmount),
    });
  }

  /// Xóa user
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Lấy số lượng users
  Future<int> getUserCount() async {
    final snapshot = await _firestore.collection(_collection).count().get();
    return snapshot.count ?? 0;
  }
}
