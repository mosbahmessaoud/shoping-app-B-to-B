// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/services/api_service.dart';

// class AdminProductsScreen extends StatefulWidget {
//   const AdminProductsScreen({super.key});

//   @override
//   State<AdminProductsScreen> createState() => _AdminProductsScreenState();
// }

// class _AdminProductsScreenState extends State<AdminProductsScreen> {
//   final ApiService _api = ApiService();
//   List<dynamic> _products = [];
//   List<dynamic> _categories = [];
//   bool _loading = true;
//   int? _selectedCategory;
//   bool? _isActiveFilter;

//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//     _loadProducts();
//   }

//   void _showErrorDialog(String title, String message, {VoidCallback? onRetry}) {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.red, size: 28),
//             const SizedBox(width: 12),
//             Expanded(child: Text(title)),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(message, style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('💡 Solutions possibles:',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Text('• Vérifiez votre connexion internet'),
//                     Text('• Réessayez dans quelques instants'),
//                     Text('• Contactez l\'administrateur si le problème persiste'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fermer'),
//           ),
//           if (onRetry != null)
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.pop(context);
//                 onRetry();
//               },
//               icon: const Icon(Icons.refresh),
//               label: const Text('Réessayer'),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showSuccessSnackbar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   String _getErrorMessage(dynamic error) {
//     final errorStr = error.toString().toLowerCase();
//     if (errorStr.contains('host lookup') ||
//         errorStr.contains('failed host lookup') ||
//         errorStr.contains('socketexception')) {
//       return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
//     } else if (errorStr.contains('timeout')) {
//       return 'Le serveur met trop de temps à répondre. Veuillez réessayer.';
//     } else if (errorStr.contains('401')) {
//       return 'Votre session a expiré. Veuillez vous reconnecter.';
//     } else if (errorStr.contains('404')) {
//       return 'Ressource introuvable. Veuillez actualiser la page.';
//     } else if (errorStr.contains('500')) {
//       return 'Le serveur rencontre un problème. Veuillez réessayer plus tard.';
//     }
//     return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final response = await _api.getAllCategories();
//       setState(() => _categories = response.data);
//     } catch (e) {
//       _showErrorDialog(
//         'Erreur de chargement',
//         'Impossible de charger les catégories.\n\n${_getErrorMessage(e)}',
//         onRetry: _loadCategories,
//       );
//     }
//   }

//   Future<void> _loadProducts() async {
//     setState(() => _loading = true);
//     try {
//       final response = await _api.getAllProducts(
//         categoryId: _selectedCategory,
//         isActive: _isActiveFilter,
//       );
//       setState(() {
//         _products = response.data;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       _showErrorDialog(
//         'Erreur de chargement',
//         'Impossible de charger les produits.\n\n${_getErrorMessage(e)}',
//         onRetry: _loadProducts,
//       );
//     }
//   }

//   Future<void> _deleteProduct(int id, String name) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.warning, color: Colors.orange, size: 28),
//             SizedBox(width: 12),
//             Text('Confirmer la suppression'),
//           ],
//         ),
//         content: Text('Êtes-vous sûr de vouloir supprimer "$name"?\n\nCette action est irréversible.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Supprimer'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await _api.deleteProduct(id);
//         _showSuccessSnackbar('Produit "$name" supprimé avec succès');
//         _loadProducts();
//       } catch (e) {
//         _showErrorDialog(
//           'Erreur de suppression',
//           'Impossible de supprimer le produit "$name".\n\n${_getErrorMessage(e)}',
//           onRetry: () => _deleteProduct(id, name),
//         );
//       }
//     }
//   }

//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Filtrer les produits'),
//         content: StatefulBuilder(
//           builder: (context, setDialogState) => Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButtonFormField<int?>(
//                 value: _selectedCategory,
//                 decoration: const InputDecoration(
//                   labelText: 'Catégorie',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.category),
//                 ),
//                 items: [
//                   const DropdownMenuItem(value: null, child: Text('Toutes les catégories')),
//                   ..._categories.map((cat) => DropdownMenuItem(
//                         value: cat['id'],
//                         child: Text(cat['name'] ?? ''),
//                       )),
//                 ],
//                 onChanged: (val) => setDialogState(() => _selectedCategory = val),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<bool?>(
//                 value: _isActiveFilter,
//                 decoration: const InputDecoration(
//                   labelText: 'Statut',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.toggle_on),
//                 ),
//                 items: const [
//                   DropdownMenuItem(value: null, child: Text('Tous les statuts')),
//                   DropdownMenuItem(value: true, child: Text('Actifs uniquement')),
//                   DropdownMenuItem(value: false, child: Text('Inactifs uniquement')),
//                 ],
//                 onChanged: (val) => setDialogState(() => _isActiveFilter = val),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _selectedCategory = null;
//                 _isActiveFilter = null;
//               });
//               Navigator.pop(ctx);
//               _loadProducts();
//             },
//             child: const Text('Réinitialiser'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               _loadProducts();
//             },
//             child: const Text('Appliquer'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _updateStock(int id, String name, int currentStock) async {
//     final controller = TextEditingController(text: currentStock.toString());

//     final newStock = await showDialog<int>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.inventory, color: Colors.blue),
//                 SizedBox(width: 8),
//                 Text('Modifier le stock'),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               name,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//             ),
//           ],
//         ),
//         content: TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             labelText: 'Nouvelle quantité',
//             border: const OutlineInputBorder(),
//             suffixText: 'unités',
//             helperText: 'Stock actuel: $currentStock unités',
//           ),
//           keyboardType: TextInputType.number,
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final qty = int.tryParse(controller.text);
//               if (qty != null && qty >= 0) {
//                 Navigator.pop(ctx, qty);
//               } else {
//                 ScaffoldMessenger.of(ctx).showSnackBar(
//                   const SnackBar(
//                     content: Text('Veuillez entrer un nombre valide'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Confirmer'),
//           ),
//         ],
//       ),
//     );

//     if (newStock != null) {
//       try {
//         await _api.updateProductStock(id, newStock);
//         _showSuccessSnackbar('Stock de "$name" mis à jour: $newStock unités');
//         _loadProducts();
//       } catch (e) {
//         _showErrorDialog(
//           'Erreur de mise à jour',
//           'Impossible de mettre à jour le stock de "$name".\n\n${_getErrorMessage(e)}',
//           onRetry: () => _updateStock(id, name, currentStock),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasFilters = _selectedCategory != null || _isActiveFilter != null;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Produits Médicaux'),
//         actions: [
//           if (hasFilters)
//             IconButton(
//               icon: const Badge(child: Icon(Icons.filter_list)),
//               onPressed: _showFilterDialog,
//               tooltip: 'Filtres actifs',
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.filter_list),
//               onPressed: _showFilterDialog,
//               tooltip: 'Filtrer',
//             ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadProducts,
//             tooltip: 'Actualiser',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           final result = await context.push('/admin/product/add');
//           if (result == true) _loadProducts();
//         },
//         icon: const Icon(Icons.add),
//         label: const Text('Nouveau'),
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadProducts,
//               child: _products.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.inventory_2_outlined,
//                               size: 64, color: Colors.grey[400]),
//                           const SizedBox(height: 16),
//                           Text('Aucun produit trouvé',
//                               style: TextStyle(
//                                   fontSize: 18, color: Colors.grey[600])),
//                           if (hasFilters) ...[
//                             const SizedBox(height: 8),
//                             Text('Essayez de modifier les filtres',
//                                 style: TextStyle(color: Colors.grey[500])),
//                             const SizedBox(height: 16),
//                             ElevatedButton.icon(
//                               onPressed: () {
//                                 setState(() {
//                                   _selectedCategory = null;
//                                   _isActiveFilter = null;
//                                 });
//                                 _loadProducts();
//                               },
//                               icon: const Icon(Icons.clear),
//                               label: const Text('Effacer les filtres'),
//                             ),
//                           ] else ...[
//                             const SizedBox(height: 8),
//                             Text('Commencez par ajouter des produits',
//                                 style: TextStyle(color: Colors.grey[500])),
//                           ],
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: _products.length,
//                       itemBuilder: (ctx, i) => _ProductCard(
//                         product: _products[i],
//                         onEdit: () async {
//                           final result = await context.push(
//                             '/admin/product/edit/${_products[i]['id']}',
//                           );
//                           if (result == true) _loadProducts();
//                         },
//                         onDelete: () => _deleteProduct(
//                           _products[i]['id'],
//                           _products[i]['name'] ?? '',
//                         ),
//                         onUpdateStock: () => _updateStock(
//                           _products[i]['id'],
//                           _products[i]['name'] ?? '',
//                           _products[i]['quantity_in_stock'] ?? 0,
//                         ),
//                       ),
//                     ),
//             ),
//     );
//   }
// }

// class _ProductCard extends StatelessWidget {
//   final Map<String, dynamic> product;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onUpdateStock;

//   const _ProductCard({
//     required this.product,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onUpdateStock,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final stock = product['quantity_in_stock'] ?? 0;
//     final minLevel = product['minimum_stock_level'] ?? 10;
//     final lowStock = stock < minLevel;
//     final isActive = product['is_active'] ?? true;
//     final categoryName = product['category_name'] ?? 'Sans catégorie';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: lowStock ? 4 : 1,
//       child: ExpansionTile(
//         leading: CircleAvatar(
//           backgroundColor: lowStock
//               ? Colors.red
//               : (isActive ? Colors.green : Colors.grey),
//           child: Text(
//             '$stock',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 product['name'] ?? '',
//                 style: TextStyle(
//                   decoration: isActive ? null : TextDecoration.lineThrough,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             if (!isActive)
//               const Chip(
//                 label: Text('Inactif', style: TextStyle(fontSize: 10)),
//                 visualDensity: VisualDensity.compact,
//                 backgroundColor: Colors.grey,
//               ),
//           ],
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Text('${product['price']} DA',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green[700],
//                     )),
//                 const SizedBox(width: 16),
//                 Icon(Icons.category, size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Expanded(child: Text(categoryName, overflow: TextOverflow.ellipsis)),
//               ],
//             ),
//             if (lowStock) ...[
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   const Icon(Icons.warning, size: 16, color: Colors.red),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Stock faible (min: $minLevel)',
//                     style: const TextStyle(
//                       color: Colors.red,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (product['description'] != null &&
//                     product['description'].toString().isNotEmpty) ...[
//                   const Text('Description:',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 4),
//                   Text(product['description']),
//                   const SizedBox(height: 12),
//                 ],
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _InfoChip(
//                         icon: Icons.inventory,
//                         label: 'Stock',
//                         value: '$stock unités',
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: _InfoChip(
//                         icon: Icons.trending_down,
//                         label: 'Min',
//                         value: '$minLevel',
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: onUpdateStock,
//                       icon: const Icon(Icons.edit, size: 16),
//                       label: const Text('Modifier Stock'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: onEdit,
//                       icon: const Icon(Icons.edit, size: 16),
//                       label: const Text('Modifier'),
//                     ),
//                     OutlinedButton.icon(
//                       onPressed: onDelete,
//                       icon: const Icon(Icons.delete, size: 16),
//                       label: const Text('Supprimer'),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _InfoChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[700]),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }