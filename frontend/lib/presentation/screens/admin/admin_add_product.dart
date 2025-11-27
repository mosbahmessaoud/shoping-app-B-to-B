import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class AdminAddProductScreen extends StatefulWidget {
  final int? productId; // For edit mode
  
  const AdminAddProductScreen({super.key, this.productId});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
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
  bool _loadingCategories = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;
    _loadCategories();
    if (_isEditMode) _loadProduct();
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

  Future<void> _loadCategories() async {
    try {
      final response = await _api.getAllCategories();
      setState(() {
        _categories = response.data;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement catégories: $e')),
        );
      }
    }
  }

  Future<void> _loadProduct() async {
    try {
      final response = await _api.getProductById(widget.productId!);
      final product = response.data;
      
      setState(() {
        _nameController.text = product['name'] ?? '';
        _descriptionController.text = product['description'] ?? '';
        _priceController.text = product['price']?.toString() ?? '';
        _quantityController.text = product['quantity_in_stock']?.toString() ?? '';
        _minStockController.text = product['minimum_stock_level']?.toString() ?? '';
        _imageUrlController.text = product['image_url'] ?? '';
        _selectedCategoryId = product['category_id'];
        _isActive = product['is_active'] ?? true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement produit: $e')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
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

      if (_isEditMode) {
        await _api.updateProduct(widget.productId!, data);
      } else {
        await _api.createProduct(data);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode 
            ? 'Produit modifié avec succès' 
            : 'Produit ajouté avec succès')),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier Produit' : 'Ajouter Produit'),
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
      body: _loadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : () => context.pop(),
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
                          onPressed: _loading ? null : _saveProduct,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isEditMode ? 'Modifier' : 'Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}