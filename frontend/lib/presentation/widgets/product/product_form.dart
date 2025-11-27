import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/category_model.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';

class ProductForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final List<Category> categories;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;

  const ProductForm({
    super.key,
    this.initialData,
    required this.categories,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  late TextEditingController _imageUrlController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name']);
    _descriptionController = TextEditingController(text: widget.initialData?['description']);
    _priceController = TextEditingController(text: widget.initialData?['price']?.toString());
    _quantityController = TextEditingController(text: widget.initialData?['quantity_in_stock']?.toString());
    _minStockController = TextEditingController(text: widget.initialData?['minimum_stock_level']?.toString());
    _imageUrlController = TextEditingController(text: widget.initialData?['image_url']);
    _selectedCategoryId = widget.initialData?['category_id'];
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

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      widget.onSubmit({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'quantity_in_stock': int.parse(_quantityController.text),
        'minimum_stock_level': int.parse(_minStockController.text),
        'image_url': _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
        'category_id': _selectedCategoryId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomTextField(
            label: 'Nom du produit *',
            controller: _nameController,
            prefixIcon: Icons.inventory,
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'Description',
            controller: _descriptionController,
            prefixIcon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          // Category Dropdown
          DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Catégorie *',
              prefixIcon: const Icon(Icons.category),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: widget.categories.map((cat) => DropdownMenuItem(
              value: cat.id,
              child: Text(cat.name),
            )).toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
            validator: (v) => v == null ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'Prix (DA) *',
            controller: _priceController,
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Quantité *',
                  controller: _quantityController,
                  prefixIcon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Stock Min *',
                  controller: _minStockController,
                  prefixIcon: Icons.warning,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'URL Image',
            controller: _imageUrlController,
            prefixIcon: Icons.image,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),
          
          CustomButton(
            text: widget.initialData == null ? 'Créer Produit' : 'Mettre à jour',
            icon: Icons.save,
            onPressed: _submit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}