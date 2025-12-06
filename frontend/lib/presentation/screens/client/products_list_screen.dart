import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  int? _selectedCategory;
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.getAllProducts(categoryId: _selectedCategory, isActive: true),
        _api.getAllCategories(),
      ]);
      
      setState(() {
        _products = results[0].data;
        _categories = results[1].data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<dynamic> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) {
      final name = (p['name'] ?? '').toLowerCase();
      final description = (p['description'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits Médicaux'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.push('/client/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('Aucun produit trouvé', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        : _isGridView ? _buildGridView() : _buildListView(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un produit...',
          hintStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 10 : 16,
          ),
        ),
        style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      height: isSmallScreen ? 45 : 50,
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: Text(
              'Tous',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
            selected: _selectedCategory == null,
            onSelected: (selected) {
              setState(() => _selectedCategory = null);
              _loadData();
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 6 : 8,
            ),
          ),
          const SizedBox(width: 8),
          ...(_categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    cat['name'] ?? '',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  ),
                  selected: _selectedCategory == cat['id'],
                  onSelected: (selected) {
                    setState(() => _selectedCategory = selected ? cat['id'] : null);
                    _loadData();
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                ),
              ))),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ?  1 : screenWidth < 600 ? 2  :screenWidth < 950 ?  3 : 4;
    final isSmallScreen = screenWidth < 360;

    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (ctx, i) => _ProductGridCard(product: _filteredProducts[i]),
    );
  }

  Widget _buildListView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: _filteredProducts.length,
      itemBuilder: (ctx, i) => _ProductListCard(product: _filteredProducts[i]),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductGridCard({required this.product});

  String? get _imageUrl {
    final imageUrls = product['image_urls'];
    if (imageUrls == null) return null;
    
    if (imageUrls is List && imageUrls.isNotEmpty) {
      return imageUrls[0].toString();
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final inStock = (product['quantity_in_stock'] ?? 0) > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/client/product/${product['id']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.medical_services,
                                  size: isSmallScreen ? 36 : 48,
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
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.medical_services,
                              size: isSmallScreen ? 36 : 48,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                  
                  if (!inStock)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                        ),
                        child: Center(
                          child: Chip(
                            label: Text(
                              'Rupture de stock',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 10,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.red,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 6 : 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  const SizedBox(height: 4),
Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${product['price']} DA',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ),
                        if (inStock)
                          Icon(
                            Icons.add_shopping_cart,
                            size: isSmallScreen ? 18 : 20,
                          ),
                      ],
                    ),                ],
              ),
            ),
            // Expanded(
            //   flex: 2,
            //   child: Padding(
            //     padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Flexible(
            //           child: Text(
            //             product['name'] ?? '',
            //             maxLines: 2,
            //             overflow: TextOverflow.ellipsis,
            //             style: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               fontSize: isSmallScreen ? 12 : 13,
            //             ),
            //           ),
            //         ),
            //         const SizedBox(height: 1),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Flexible(
            //               child: FittedBox(
            //                 fit: BoxFit.scaleDown,
            //                 alignment: Alignment.centerLeft,
            //                 child: Text(
            //                   '${product['price']} DA',
            //                   style: TextStyle(
            //                     color: Theme.of(context).colorScheme.primary,
            //                     fontWeight: FontWeight.bold,
            //                     fontSize: isSmallScreen ? 14 : 16,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //             if (inStock)
            //               Icon(
            //                 Icons.add_shopping_cart,
            //                 size: isSmallScreen ? 18 : 20,
            //               ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductListCard({required this.product});

  String? get _imageUrl {
    final imageUrls = product['image_urls'];
    if (imageUrls == null) return null;
    
    if (imageUrls is List && imageUrls.isNotEmpty) {
      return imageUrls[0].toString();
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final inStock = (product['quantity_in_stock'] ?? 0) > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;
    
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/client/product/${product['id']}'),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
                height: isSmallScreen ? 50 : (isMediumScreen ? 60 : 70),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageUrl != null
                    ? Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.medical_services,
                            size: isSmallScreen ? 24 : 28,
                            color: Colors.grey[400],
                          );
                        },
                      )
                    : Icon(
                        Icons.medical_services,
                        size: isSmallScreen ? 24 : 28,
                        color: Colors.grey[400],
                      ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product['description'] != null) ...[
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        product['description'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      product['category_name'] ?? 'Sans catégorie',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: isSmallScreen ? 8 : 12),
              
              // Price and stock
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${product['price']} DA',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                  if (!inStock) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Rupture',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}