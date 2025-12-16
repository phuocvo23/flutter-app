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
}

/// Simple cart state management
class CartState {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => List.unmodifiable(_items);

  static int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  static double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  static double get shippingFee => subtotal > 500000 ? 0 : 30000;

  static double get total => subtotal + shippingFee;

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
  }

  static void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  static void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length && quantity > 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
  }

  static void clear() {
    _items.clear();
  }
}
