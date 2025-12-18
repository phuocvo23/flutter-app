import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';

/// Service để quản lý orders trong Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  /// Lấy tất cả orders
  Stream<List<Order>> getAll() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy orders theo status
  Stream<List<Order>> getByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy orders theo customerId (cho user xem đơn hàng của mình)
  Stream<List<Order>> getByCustomerId(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList(),
        );
  }

  /// Lấy order theo ID
  Future<Order?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Order.fromFirestore(doc);
    }
    return null;
  }

  /// Thêm order mới
  Future<String> add(Order order) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(order.toFirestore());
    return docRef.id;
  }

  /// Cập nhật order
  Future<void> update(Order order) async {
    await _firestore
        .collection(_collection)
        .doc(order.id)
        .update(order.toFirestore());
  }

  /// Cập nhật status
  Future<void> updateStatus(String orderId, String status) async {
    await _firestore.collection(_collection).doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xóa order
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Lấy tổng doanh thu
  Future<double> getTotalRevenue() async {
    final snapshot =
        await _firestore
            .collection(_collection)
            .where('status', isEqualTo: 'Completed')
            .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['totalAmount'] ?? 0).toDouble();
    }
    return total;
  }

  /// Lấy số lượng orders
  Future<int> getOrderCount() async {
    final snapshot = await _firestore.collection(_collection).count().get();
    return snapshot.count ?? 0;
  }

  /// Lấy recent orders (giới hạn số lượng)
  Stream<List<Order>> getRecent({int limit = 5}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList(),
        );
  }
}
