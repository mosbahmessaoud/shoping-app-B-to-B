import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';

  // Get all cart items
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    
    if (cartJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(cartJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Add item to cart
  Future<void> addToCart(Map<String, dynamic> product, int quantity) async {
    final cart = await getCartItems();
    
    // Check if product already exists in cart
    final existingIndex = cart.indexWhere((item) => item['id'] == product['id']);
    
    if (existingIndex >= 0) {
      // Update quantity if product exists
      cart[existingIndex]['quantity'] = (cart[existingIndex]['quantity'] as int) + quantity;
    } else {
      // Add new product to cart
      cart.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': quantity,
        'image_url': product['image_url'],
        'category_name': product['category']?['name'] ?? 'Sans catégorie',
        'quantity_in_stock': product['quantity_in_stock'],
      });
    }
    
    await _saveCart(cart);
  }

  // Update item quantity
  Future<void> updateQuantity(int productId, int newQuantity) async {
    final cart = await getCartItems();
    
    if (newQuantity <= 0) {
      // Remove item if quantity is 0 or less
      cart.removeWhere((item) => item['id'] == productId);
    } else {
      // Update quantity
      final index = cart.indexWhere((item) => item['id'] == productId);
      if (index >= 0) {
        cart[index]['quantity'] = newQuantity;
      }
    }
    
    await _saveCart(cart);
  }

  // Remove item from cart
  Future<void> removeFromCart(int productId) async {
    final cart = await getCartItems();
    cart.removeWhere((item) => item['id'] == productId);
    await _saveCart(cart);
  }

  // Clear entire cart
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // Get cart item count
// Get cart item count
  Future<int> getCartCount() async {
    final cart = await getCartItems();
    return cart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
  }

  // Get cart total
  // Get cart total
  Future<double> getCartTotal() async {
    final cart = await getCartItems();
    return cart.fold<double>(0.0, (sum, item) => 
      sum + ((item['price'] as num) * (item['quantity'] as int)));
  }

  // Private method to save cart
  Future<void> _saveCart(List<Map<String, dynamic>> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cart);
    await prefs.setString(_cartKey, cartJson);
  }

  // Check if product is in cart
  Future<bool> isInCart(int productId) async {
    final cart = await getCartItems();
    return cart.any((item) => item['id'] == productId);
  }

  // Get quantity of specific product in cart
  Future<int> getProductQuantity(int productId) async {
    final cart = await getCartItems();
    final item = cart.firstWhere(
      (item) => item['id'] == productId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] as int;
  }
}