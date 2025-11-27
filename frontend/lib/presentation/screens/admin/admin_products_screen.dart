import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  int? _selectedCategory ;
  bool? _isActiveFilter;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _api.getAllCategories();
      setState(() => _categories = response.data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement catégories: $e')),
        );
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      print(_selectedCategory);
      final response = await _api.getAllProducts(
        categoryId: _selectedCategory,
        isActive: _isActiveFilter,
      );
      setState(() {
        _products = response.data;
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

  Future<void> _deleteProduct(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer "$name"?\nCette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteProduct(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit supprimé avec succès')),
          );
        }
        _loadProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur suppression: $e')),
          );
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filtrer les produits'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int?>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Toutes')),
                  ..._categories.map((cat) => DropdownMenuItem(
                        value: cat['id'],
                        child: Text(cat['name'] ?? ''),
                      )),
                ],
                onChanged: (val) => setDialogState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<bool?>(
                value: _isActiveFilter,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tous')),
                  DropdownMenuItem(value: true, child: Text('Actifs')),
                  DropdownMenuItem(value: false, child: Text('Inactifs')),
                ],
                onChanged: (val) => setDialogState(() => _isActiveFilter = val),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _isActiveFilter = null;
              });
              Navigator.pop(ctx);
              _loadProducts();
            },
            child: const Text('Réinitialiser'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadProducts();
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStock(int id, String name, int currentStock) async {
    final controller = TextEditingController(text: currentStock.toString());
    
    final newStock = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modifier Stock - $name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nouvelle quantité',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text);
              if (qty != null) Navigator.pop(ctx, qty);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (newStock != null) {
      try {
        await _api.updateProductStock(id, newStock);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock mis à jour')),
          );
        }
        _loadProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = _selectedCategory != null || _isActiveFilter != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits Médicaux'),
        actions: [
          if (hasFilters)
            IconButton(
              icon: const Badge(child: Icon(Icons.filter_list)),
              onPressed: _showFilterDialog,
              tooltip: 'Filtres actifs',
            )
          else
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              tooltip: 'Filtrer',
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/admin/product/add');
          if (result == true) _loadProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, 
                            size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('Aucun produit trouvé',
                            style: TextStyle(color: Colors.grey[600])),
                          if (hasFilters) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = null;
                                  _isActiveFilter = null;
                                });
                                _loadProducts();
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Effacer les filtres'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _products.length,
                      itemBuilder: (ctx, i) => _ProductCard(
                        product: _products[i],
                        onEdit: () async {
                          final result = await context.push(
                            '/admin/product/edit/${_products[i]['id']}',
                          );
                          if (result == true) _loadProducts();
                        },
                        onDelete: () => _deleteProduct(
                          _products[i]['id'],
                          _products[i]['name'] ?? '',
                        ),
                        onUpdateStock: () => _updateStock(
                          _products[i]['id'],
                          _products[i]['name'] ?? '',
                          _products[i]['quantity_in_stock'] ?? 0,
                        ),
                      ),
                    ),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdateStock;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    final stock = product['quantity_in_stock'] ?? 0;
    final minLevel = product['minimum_stock_level'] ?? 10;
    final lowStock = stock < minLevel;
    final isActive = product['is_active'] ?? true;
    final categoryName = product['category_name'] ?? 'Sans catégorie';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: lowStock 
            ? Colors.red 
            : (isActive ? Colors.green : Colors.grey),
          child: Text(
            '$stock',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product['name'] ?? '',
                style: TextStyle(
                  decoration: isActive ? null : TextDecoration.lineThrough,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isActive)
              const Chip(
                label: Text('Inactif', style: TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.grey,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${product['price']} DA', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  )),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(categoryName),
              ],
            ),
            if (lowStock) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Stock faible (min: $minLevel)',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product['description'] != null && 
                    product['description'].toString().isNotEmpty) ...[
                  const Text('Description:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(product['description']),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.inventory,
                        label: 'Stock',
                        value: '$stock unités',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.trending_down,
                        label: 'Min',
                        value: '$minLevel',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onUpdateStock,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(height: 4),
          Text(label, 
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(value, 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}