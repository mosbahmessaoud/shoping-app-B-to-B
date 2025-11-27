import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _api = ApiService();
  final CartService _cartService = CartService();
  Map<String, dynamic>? _product;
  bool _loading = true;
  bool _addingToCart = false;
  int _quantity = 1;
  int _cartQuantity = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getProductById(int.parse(widget.productId));
      final cartQty = await _cartService.getProductQuantity(int.parse(widget.productId));
      
      setState(() {
        _product = response.data;
        _cartQuantity = cartQty;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;
    
    setState(() => _addingToCart = true);
    
    try {
      await _cartService.addToCart(_product!, _quantity);
      
      setState(() {
        _cartQuantity += _quantity;
        _addingToCart = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_quantity x ${_product!['name']} ajouté au panier'),
            action: SnackBarAction(
              label: 'Voir Panier',
              onPressed: () => context.push('/client/cart'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _addingToCart = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails Produit')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails Produit')),
        body: const Center(child: Text('Produit introuvable')),
      );
    }

    final stock = _product!['quantity_in_stock'] ?? 0;
    final inStock = stock > 0;
    final price = _product!['price'] ?? 0;
    final availableStock = stock - _cartQuantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails Produit'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text(''),
              child: Icon(Icons.shopping_cart),
            ),
            onPressed: () => context.push('/client/cart'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Product Image
          Container(
            height: 300,
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.medical_services,
                size: 120,
                color: Colors.grey[400],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name & Category
                Text(
                  _product!['name'] ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Chip(
                  avatar: const Icon(Icons.category, size: 16),
                  label: Text(_product!['category']?['name'] ?? 'Sans catégorie'),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                
                // Price
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prix',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$price DA',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Stock Status
                Card(
                  color: inStock ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          inStock ? Icons.check_circle : Icons.cancel,
                          color: inStock ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inStock 
                                  ? 'En stock ($stock unités disponibles)' 
                                  : 'Rupture de stock',
                                style: TextStyle(
                                  color: inStock ? Colors.green.shade900 : Colors.red.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_cartQuantity > 0)
                                Text(
                                  'Déjà $_cartQuantity dans le panier',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description
                if (_product!['description'] != null && 
                    _product!['description'].toString().isNotEmpty) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!['description'],
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Quantity Selector
                if (inStock && availableStock > 0) ...[
                  Text(
                    'Quantité',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: _quantity > 1 
                          ? () => setState(() => _quantity--) 
                          : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$_quantity',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: _quantity < availableStock 
                          ? () => setState(() => _quantity++) 
                          : null,
                        icon: const Icon(Icons.add),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                                'Total: ${(double.parse(price.toString()) * _quantity).toStringAsFixed(2)} DA',                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Out of stock warning
                if (availableStock <= 0 && stock > 0)
                  Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vous avez déjà tout le stock disponible dans votre panier',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: inStock && availableStock > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _addingToCart ? null : _addToCart,
                  icon: _addingToCart
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  label: Text(_addingToCart ? 'Ajout...' : 'Ajouter au panier'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}