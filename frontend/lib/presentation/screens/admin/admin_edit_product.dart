import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class AdminEditProductScreen extends StatefulWidget {
  final String productId;
  
  const AdminEditProductScreen({super.key, required this.productId});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  List<dynamic> _categories = [];
  int? _selectedCategoryId;
  bool _isActive = true;
  bool _loading = false;
  bool _loadingData = true;
  Map<String, dynamic>? _originalProduct;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loadingData = true);
    try {
      final productId = int.parse(widget.productId);
      
      // Load categories and product in parallel
      final results = await Future.wait([
        _api.getAllCategories(),
        _api.getProductById(productId),
      ]);
      
      final categoriesResponse = results[0];
      final productResponse = results[1];
      final product = productResponse.data;
      
      setState(() {
        _categories = categoriesResponse.data;
        _originalProduct = product;
        
        // Populate form fields
        _nameController.text = product['name'] ?? '';
        _descriptionController.text = product['description'] ?? '';
        _priceController.text = product['price']?.toString() ?? '';
        _quantityController.text = product['quantity_in_stock']?.toString() ?? '';
        _minStockController.text = product['minimum_stock_level']?.toString() ?? '';
        _imageUrlController.text = product['image_url'] ?? '';
        _selectedCategoryId = product['category_id'];
        _isActive = product['is_active'] ?? true;
        
        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final productId = int.parse(widget.productId);
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'quantity_in_stock': int.parse(_quantityController.text),
        'minimum_stock_level': int.parse(_minStockController.text),
        'category_id': _selectedCategoryId,
        'is_active': _isActive,
        if (_imageUrlController.text.isNotEmpty) 
          'image_url': _imageUrlController.text.trim(),
      };

      await _api.updateProduct(productId, data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _hasChanges() {
    if (_originalProduct == null) return false;
    
    return _nameController.text != (_originalProduct!['name'] ?? '') ||
           _descriptionController.text != (_originalProduct!['description'] ?? '') ||
           _priceController.text != (_originalProduct!['price']?.toString() ?? '') ||
           _quantityController.text != (_originalProduct!['quantity_in_stock']?.toString() ?? '') ||
           _minStockController.text != (_originalProduct!['minimum_stock_level']?.toString() ?? '') ||
           _imageUrlController.text != (_originalProduct!['image_url'] ?? '') ||
           _selectedCategoryId != _originalProduct!['category_id'] ||
           _isActive != (_originalProduct!['is_active'] ?? true);
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) return true;
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifications non enregistrées'),
        content: const Text('Voulez-vous quitter sans enregistrer les modifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges(),
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges()) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifier Produit'),
          actions: [
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: _loadingData
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Product Info Summary Card
                    if (_originalProduct != null)
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Produit: ${_originalProduct!['name']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Catégorie: ${_originalProduct!['category_name'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // General Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informations générales',
                              style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom du produit *',
                                prefixIcon: Icon(Icons.medical_services),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) =>
                                  val?.trim().isEmpty ?? true ? 'Requis' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Catégorie *',
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((cat) {
                                return DropdownMenuItem<int>(
                                  value: cat['id'],
                                  child: Text(cat['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategoryId = val),
                              validator: (val) => val == null ? 'Requis' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Price and Stock Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prix et Stock',
                              style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Prix (DA) *',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (val) {
                                if (val?.trim().isEmpty ?? true) return 'Requis';
                                if (double.tryParse(val!) == null) return 'Prix invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _quantityController,
                                    decoration: const InputDecoration(
                                      labelText: 'Quantité *',
                                      prefixIcon: Icon(Icons.inventory),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (val) {
                                      if (val?.trim().isEmpty ?? true) return 'Requis';
                                      if (int.tryParse(val!) == null) return 'Invalide';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _minStockController,
                                    decoration: const InputDecoration(
                                      labelText: 'Stock Min *',
                                      prefixIcon: Icon(Icons.warning),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (val) {
                                      if (val?.trim().isEmpty ?? true) return 'Requis';
                                      if (int.tryParse(val!) == null) return 'Invalide';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_originalProduct != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Stock original: ${_originalProduct!['quantity_in_stock']} unités',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Other Settings Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Autres',
                              style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'URL Image (optionnel)',
                                prefixIcon: Icon(Icons.image),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              value: _isActive,
                              onChanged: (val) => setState(() => _isActive = val),
                              title: const Text('Produit actif'),
                              subtitle: Text(_isActive 
                                ? 'Visible pour les clients' 
                                : 'Masqué pour les clients'),
                              secondary: Icon(_isActive 
                                ? Icons.visibility 
                                : Icons.visibility_off),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading ? null : () async {
                              if (_hasChanges()) {
                                final shouldPop = await _onWillPop();
                                if (shouldPop && mounted) context.pop();
                              } else {
                                context.pop();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _updateProduct,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Enregistrer les modifications'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}