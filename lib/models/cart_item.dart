import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';

/// Model item trong giỏ hàng
class CartItem {
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'product': product.toFirestore(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  /// Create from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
    );
  }
}

/// Simple cart state management with persistence
class CartState {
  static final List<CartItem> _items = [];
  static const String _storageKey = 'cart_items';

  static List<CartItem> get items => List.unmodifiable(_items);

  static int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  static double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  static double get shippingFee => subtotal > 500000 ? 0 : 30000;

  static double get total => subtotal + shippingFee;

  /// Load cart from local storage
  static Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _items.clear();
        _items.addAll(
          jsonList.map((e) => CartItem.fromJson(e as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  /// Save cart to local storage
  static Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  static void addItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (i) =>
          i.product.id == item.product.id &&
          i.selectedSize == item.selectedSize &&
          i.selectedColor == item.selectedColor,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    _saveToStorage();
  }

  static void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _saveToStorage();
    }
  }

  static void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length && quantity > 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _saveToStorage();
    }
  }

  static void clear() {
    _items.clear();
    _saveToStorage();
  }
}
