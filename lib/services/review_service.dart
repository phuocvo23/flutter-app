import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

/// Service để quản lý reviews trong Firestore
class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _reviewsCollection = 'reviews';
  final String _ordersCollection = 'orders';

  /// Lấy reviews theo productId
  Stream<List<Review>> getByProductId(String productId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          final reviews =
              snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
          // Sort client-side to avoid composite index requirement
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  /// Thêm review mới
  Future<void> add(Review review) async {
    try {
      await _firestore.collection(_reviewsCollection).add(review.toFirestore());

      // Update product rating after adding review
      try {
        await _updateProductRating(review.productId);
      } catch (e) {
        print('Warning: Could not update product rating: $e');
      }
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  /// Kiểm tra user có thể đánh giá sản phẩm không (đã mua và hoàn thành đơn)
  Future<bool> canReview(String userId, String productId) async {
    if (userId.isEmpty) return false;

    // Check if already reviewed
    final hasReviewed = await this.hasReviewed(userId, productId);
    if (hasReviewed) return false;

    // Check if user has completed order with this product
    final ordersSnapshot =
        await _firestore
            .collection(_ordersCollection)
            .where('customerId', isEqualTo: userId)
            .where('status', isEqualTo: 'Completed')
            .get();

    for (var orderDoc in ordersSnapshot.docs) {
      final items = orderDoc.data()['items'] as List<dynamic>?;
      if (items != null) {
        for (var item in items) {
          if (item['productId'] == productId) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Kiểm tra user đã đánh giá sản phẩm chưa
  Future<bool> hasReviewed(String userId, String productId) async {
    if (userId.isEmpty) return false;

    final snapshot =
        await _firestore
            .collection(_reviewsCollection)
            .where('userId', isEqualTo: userId)
            .where('productId', isEqualTo: productId)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Tính rating trung bình của sản phẩm
  Stream<double> getAverageRating(String productId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0.0;

          double total = 0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['rating'] ?? 0).toDouble();
          }
          return total / snapshot.docs.length;
        });
  }

  /// Lấy số lượng reviews của sản phẩm
  Stream<int> getReviewCount(String productId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Cập nhật rating trong product document
  Future<void> _updateProductRating(String productId) async {
    final reviewsSnapshot =
        await _firestore
            .collection(_reviewsCollection)
            .where('productId', isEqualTo: productId)
            .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] ?? 0).toDouble();
    }

    final averageRating = totalRating / reviewsSnapshot.docs.length;
    final reviewCount = reviewsSnapshot.docs.length;

    await _firestore.collection('products').doc(productId).update({
      'rating': averageRating,
      'reviewCount': reviewCount,
    });
  }

  /// Xóa review
  Future<void> delete(String reviewId, String productId) async {
    await _firestore.collection(_reviewsCollection).doc(reviewId).delete();
    await _updateProductRating(productId);
  }
}
