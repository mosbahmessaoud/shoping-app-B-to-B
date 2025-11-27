import 'package:flutter/material.dart';

class CartSummaryWidget extends StatelessWidget {
  final int itemCount;
  final double totalAmount;
  final VoidCallback? onCheckout;
  final bool isLoading;

  const CartSummaryWidget({
    super.key,
    required this.itemCount,
    required this.totalAmount,
    this.onCheckout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary Rows
              _buildSummaryRow(
                'Articles',
                '$itemCount',
                theme,
                isPrice: false,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              _buildSummaryRow(
                'Total',
                '${totalAmount.toStringAsFixed(2)} DA',
                theme,
                bold: true,
              ),
              const SizedBox(height: 16),
              
              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading || itemCount == 0 ? null : onCheckout,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_cart_checkout),
                  label: Text(
                    isLoading ? 'Création en cours...' : 'Commander',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              if (itemCount == 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Ajoutez des articles pour commander',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme, {bool bold = false, bool isPrice = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: bold ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}