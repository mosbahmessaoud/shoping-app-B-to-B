import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';

class ProductListItem extends StatelessWidget {
  final ProductWithCategory product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProductListItem({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDark ? 2 : 1,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        
        // Product Image
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imageUrl != null
              ? Image.network(
                  product.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                )
              : _buildPlaceholder(theme),
        ),
        
        // Product Info
        title: Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.categoryName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.price.toStringAsFixed(2)} DA',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  product.quantityInStock > product.minimumStockLevel
                      ? Icons.check_circle
                      : Icons.warning,
                  size: 14,
                  color: product.quantityInStock > product.minimumStockLevel
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Stock: ${product.quantityInStock}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        
        // Actions
        trailing: showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Modifier',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: theme.colorScheme.error),
                      onPressed: onDelete,
                      tooltip: 'Supprimer',
                    ),
                ],
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      color: theme.colorScheme.surfaceVariant,
      child: Icon(
        Icons.image,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}