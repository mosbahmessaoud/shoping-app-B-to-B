import 'package:flutter/material.dart';
import '../../../data/models/bill_model.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;
  final String? clientName;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDark ? 3 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bill Number
                  Text(
                    bill.billNumber,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  
                  // Status Badge
                  _buildStatusBadge(theme),
                ],
              ),
              
              if (clientName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      clientName!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // Amount Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountInfo(
                    'Total',
                    bill.totalAmount,
                    theme.colorScheme.onSurface,
                    theme,
                  ),
                  _buildAmountInfo(
                    'Payé',
                    bill.totalPaid,
                    Colors.green,
                    theme,
                  ),
                  _buildAmountInfo(
                    'Restant',
                    bill.totalRemaining,
                    bill.totalRemaining > 0 ? Colors.orange : Colors.green,
                    theme,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(bill.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildStatusBadge(ThemeData theme) {
    final isPaid = bill.status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid ? Colors.green : Colors.orange,
        ),
      ),
      child: Text(
        isPaid ? 'Payée' : 'Non payée',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isPaid ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, double amount, Color color, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} DA',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}