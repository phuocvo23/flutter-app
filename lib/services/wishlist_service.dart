import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service để quản lý wishlist trong Firestore
class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _wishlistRef =>
      _firestore.collection('users').doc(_userId).collection('wishlist');

  /// Kiểm tra user đã đăng nhập chưa
  bool get isLoggedIn => _auth.currentUser != null;

  /// Thêm sản phẩm vào wishlist
  Future<void> add(String productId) async {
    if (!isLoggedIn) return;
    await _wishlistRef.doc(productId).set({
      'productId': productId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xóa sản phẩm khỏi wishlist
  Future<void> remove(String productId) async {
    if (!isLoggedIn) return;
    await _wishlistRef.doc(productId).delete();
  }

  /// Toggle sản phẩm trong wishlist
  Future<bool> toggle(String productId) async {
    if (!isLoggedIn) return false;
    final isIn = await isInWishlist(productId);
    if (isIn) {
      await remove(productId);
      return false;
    } else {
      await add(productId);
      return true;
    }
  }

  /// Kiểm tra sản phẩm có trong wishlist không
  Future<bool> isInWishlist(String productId) async {
    if (!isLoggedIn) return false;
    final doc = await _wishlistRef.doc(productId).get();
    return doc.exists;
  }

  /// Stream để check realtime
  Stream<bool> isInWishlistStream(String productId) {
    if (!isLoggedIn) return Stream.value(false);
    return _wishlistRef.doc(productId).snapshots().map((doc) => doc.exists);
  }

  /// Lấy danh sách product IDs trong wishlist
  Stream<List<String>> getProductIds() {
    if (!isLoggedIn) return Stream.value([]);
    return _wishlistRef
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Lấy số lượng sản phẩm trong wishlist
  Future<int> getCount() async {
    if (!isLoggedIn) return 0;
    final snapshot = await _wishlistRef.count().get();
    return snapshot.count ?? 0;
  }

  /// Stream số lượng
  Stream<int> getCountStream() {
    if (!isLoggedIn) return Stream.value(0);
    return _wishlistRef.snapshots().map((snapshot) => snapshot.docs.length);
  }

  /// Xóa tất cả
  Future<void> clearAll() async {
    if (!isLoggedIn) return;
    final batch = _firestore.batch();
    final docs = await _wishlistRef.get();
    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
