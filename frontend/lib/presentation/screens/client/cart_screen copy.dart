// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/services/api_service.dart';
// import '../../../core/services/cart_service.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final ApiService _api = ApiService();
//   final CartService _cartService = CartService();
  
//   List<Map<String, dynamic>> _cartItems = [];
//   bool _loading = false;
//   bool _creatingBill = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCart();
//   }

//   Future<void> _loadCart() async {
//     setState(() => _loading = true);
//     try {
//       final items = await _cartService.getCartItems();
//       setState(() {
//         _cartItems = items;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur chargement panier: $e')),
//         );
//       }
//     }
//   }

//   // Helper method to safely parse price
//   double _parsePrice(dynamic value) {
//     if (value is num) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   // Helper method to safely parse quantity
//   int _parseQuantity(dynamic value) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? 0;
//     if (value is num) return value.toInt();
//     return 0;
//   }

//   double get _total {
//     return _cartItems.fold(0.0, (sum, item) {
//       final price = _parsePrice(item['price']);
//       final quantity = _parseQuantity(item['quantity']);
//       return sum + (price * quantity);
//     });
//   }

//   Future<void> _updateQuantity(int index, int newQuantity) async {
//     final item = _cartItems[index];
//     final maxStock = _parseQuantity(item['quantity_in_stock']);
    
//     // Check stock availability
//     if (newQuantity > maxStock) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Stock maximum: $maxStock unités')),
//       );
//       return;
//     }
    
//     if (newQuantity <= 0) {
//       _removeItem(index);
//       return;
//     }
    
//     try {
//       await _cartService.updateQuantity(item['id'], newQuantity);
//       await _loadCart();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _removeItem(int index) async {
//     final item = _cartItems[index];
    
//     try {
//       await _cartService.removeFromCart(item['id']);
//       await _loadCart();
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Produit retiré du panier'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _clearCart() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Vider le panier'),
//         content: const Text('Voulez-vous vider tout le panier?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Vider'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await _cartService.clearCart();
//         await _loadCart();
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Erreur: $e')),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _createBill() async {
//     if (_cartItems.isEmpty) return;

//     setState(() => _creatingBill = true);
    
//     try {
//       // Prepare bill items according to ERD schema
//       final billItems = _cartItems.map((item) => {
//         'product_id': item['id'],
//         'quantity': _parseQuantity(item['quantity']),
//         'unit_price': _parsePrice(item['price']),
//       }).toList();

//       final billData = {
//         'items': billItems,
//       };

//       await _api.createBill(billData);
      
//       // Clear cart after successful bill creation
//       await _cartService.clearCart();
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ Facture créée avec succès!'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//           ),
//         );
        
//         // Navigate to bills screen
//         context.go('/client/bills');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur création facture: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() => _creatingBill = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Mon Panier')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Mon Panier (${_cartItems.length})'),
//         actions: [
//           if (_cartItems.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete_sweep),
//               onPressed: _clearCart,
//               tooltip: 'Vider le panier',
//             ),
//         ],
//       ),
//       body: _cartItems.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text('Votre panier est vide', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () => context.push('/client/products'),
//                     icon: const Icon(Icons.shopping_bag),
//                     label: const Text('Parcourir les produits'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _cartItems.length,
//                     itemBuilder: (ctx, i) => _CartItemCard(
//                       item: _cartItems[i],
//                       onQuantityChanged: (qty) => _updateQuantity(i, qty),
//                       onRemove: () => _removeItem(i),
//                       parsePrice: _parsePrice,
//                       parseQuantity: _parseQuantity,
//                     ),
//                   ),
//                 ),
//                 _buildSummary(),
//               ],
//             ),
//     );
//   }

//   Widget _buildSummary() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 Text(
//                   '${_total.toStringAsFixed(2)} DA',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _creatingBill ? null : _createBill,
//                 icon: _creatingBill 
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                     )
//                   : const Icon(Icons.receipt_long),
//                 label: Text(_creatingBill ? 'Création...' : 'Créer la facture'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.all(16),
//                   textStyle: const TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CartItemCard extends StatelessWidget {
//   final Map<String, dynamic> item;
//   final Function(int) onQuantityChanged;
//   final VoidCallback onRemove;
//   final double Function(dynamic) parsePrice;
//   final int Function(dynamic) parseQuantity;

//   const _CartItemCard({
//     required this.item,
//     required this.onQuantityChanged,
//     required this.onRemove,
//     required this.parsePrice,
//     required this.parseQuantity,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final quantity = parseQuantity(item['quantity']);
//     final price = parsePrice(item['price']);
//     final subtotal = price * quantity;
//     final maxStock = parseQuantity(item['quantity_in_stock']);

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.medical_services, size: 40, color: Colors.grey[400]),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item['name'] ?? '',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${price.toStringAsFixed(2)} DA',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Stock: $maxStock unités',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => onQuantityChanged(quantity - 1),
//                         icon: const Icon(Icons.remove_circle_outline),
//                         iconSize: 28,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Text(
//                           '$quantity',
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: quantity < maxStock 
//                           ? () => onQuantityChanged(quantity + 1)
//                           : null,
//                         icon: const Icon(Icons.add_circle_outline),
//                         iconSize: 28,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   onPressed: onRemove,
//                   icon: const Icon(Icons.delete_outline, color: Colors.red),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '${subtotal.toStringAsFixed(2)} DA',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }