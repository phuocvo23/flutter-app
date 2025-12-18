import 'package:cloud_firestore/cloud_firestore.dart';

/// Model người dùng app
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final int totalOrders;
  final double totalSpent;
  final String status; // Active, Inactive, Pending
  final String? address;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.status = 'Active',
    this.address,
    this.createdAt,
    this.lastLoginAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      avatarUrl: data['avatarUrl'],
      totalOrders: data['totalOrders'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      status: data['status'] ?? 'Active',
      address: data['address'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'status': status,
      'address': address,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt ?? FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? totalOrders,
    double? totalSpent,
    String? status,
    String? address,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      status: status ?? this.status,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
