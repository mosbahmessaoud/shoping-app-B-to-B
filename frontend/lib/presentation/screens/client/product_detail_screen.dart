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
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // Helper to get image URLs list
  List<String> get _imageUrls {
    if (_product == null) return [];
    
    final imageUrls = _product!['image_urls'];
    if (imageUrls == null) return [];
    
    if (imageUrls is List) {
      return imageUrls.map((url) => url.toString()).toList();
    }
    
    return [];
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
        _showSmoothNotification(
          message: 'Erreur: $e',
          isError: true,
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
        _showSmoothNotification(
          message: '$_quantity x ${_product!['name']} ajouté au panier',
          isError: false,
          showAction: true,
        );
      }
    } catch (e) {
      setState(() => _addingToCart = false);
      if (mounted) {
        _showSmoothNotification(
          message: 'Erreur: $e',
          isError: true,
        );
      }
    }
  }

  void _showSmoothNotification({
    required String message,
    required bool isError,
    bool showAction = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _SmoothNotification(
        message: message,
        isError: isError,
        showAction: showAction,
        onActionPressed: showAction
            ? () {
                overlayEntry.remove();
                context.push('/client/cart');
              }
            : null,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
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
    final images = _imageUrls;

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
          // Product Image Gallery
          _buildImageGallery(images),
          
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
                  label: Text(_product!['category_name'] ?? 'Sans catégorie'),
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
                          'Total: ${(double.parse(price.toString()) * _quantity).toStringAsFixed(2)} DA',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) {
      // No images - show placeholder
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.medical_services,
            size: 120,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    if (images.length == 1) {
      // Single image - no carousel needed
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: Image.network(
          images[0],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.medical_services,
                size: 120,
                color: Colors.grey[400],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    }

    // Multiple images - show carousel with indicators
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey[200],
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.medical_services,
                        size: 120,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // Image indicators
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Smooth Notification Widget
class _SmoothNotification extends StatefulWidget {
  final String message;
  final bool isError;
  final bool showAction;
  final VoidCallback? onActionPressed;
  final VoidCallback onDismiss;

  const _SmoothNotification({
    required this.message,
    required this.isError,
    required this.showAction,
    this.onActionPressed,
    required this.onDismiss,
  });

  @override
  State<_SmoothNotification> createState() => _SmoothNotificationState();
}

class _SmoothNotificationState extends State<_SmoothNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: widget.isError ? Colors.red.shade600 : Colors.green.shade600,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.showAction && widget.onActionPressed != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: widget.onActionPressed,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'VOIR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}