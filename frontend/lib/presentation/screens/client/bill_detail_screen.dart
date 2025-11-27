import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class BillDetailScreen extends StatefulWidget {
  final String billId;
  
  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _bill;
  List<dynamic> _payments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  // Safe conversion function that handles String, int, double, and null
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse "$value" as double: $e');
        return 0.0;
      }
    }
    return 0.0;
  }

  Future<void> _loadBillDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final billId = int.parse(widget.billId);
      
      print('🔍 Loading bill details for ID: $billId');
      
      // Load bill details
      final billResponse = await _api.getBillById(billId);
      print('✅ Bill response: ${billResponse.data}');
      
      // Load payment history
      List<dynamic> payments = [];
      try {
        final paymentsResponse = await _api.getBillPaymentHistory(billId);
        payments = paymentsResponse.data ?? [];
        print('✅ Payments response: $payments');
      } catch (e) {
        print('⚠️ No payments found: $e');
        // It's OK if there are no payments yet
      }
      
      setState(() {
        _bill = billResponse.data;
        _payments = payments;
        _loading = false;
      });
    } catch (e) {
      print('❌ Error loading bill: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement facture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.orange;
      case 'unpaid':
      case 'not paid': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'paid': return 'Payée';
      case 'partial': return 'Partielle';
      case 'unpaid':
      case 'not paid': return 'Impayée';
      default: return 'Inconnu';
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatDateTime(String? date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails Facture')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails Facture')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _error != null ? 'Erreur de chargement' : 'Facture introuvable',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBillDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final status = _bill!['status'];
    final items = _bill!['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Facture #${_bill!['bill_number'] ?? widget.billId}'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBillDetails,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(status),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildItemsSection(items),
            const SizedBox(height: 16),
            if (_payments.isNotEmpty) _buildPaymentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String? status) {
    final statusColor = _getStatusColor(status);
    
    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              status == 'paid' ? Icons.check_circle : 
              status == 'partial' ? Icons.timelapse : Icons.pending,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut: ${_getStatusLabel(status)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(_bill!['created_at'])}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  if (_bill!['notification_sent'] == true)
                    Row(
                      children: [
                        Icon(Icons.notifications_active, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Notification envoyée',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Use _toDouble() helper to safely convert values
    final totalAmount = _toDouble(_bill!['total_amount']);
    final totalPaid = _toDouble(_bill!['total_paid']);
    final remaining = _toDouble(_bill!['total_remaining']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé Financier',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Montant Total',
              value: '${totalAmount.toStringAsFixed(2)} DA',
              bold: true,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Montant Payé',
              value: '${totalPaid.toStringAsFixed(2)} DA',
              color: Colors.green,
            ),
            if (remaining > 0) ...[
              const Divider(),
              _SummaryRow(
                label: 'Reste à Payer',
                value: '${remaining.toStringAsFixed(2)} DA',
                color: Colors.orange,
                bold: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(List<dynamic> items) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Aucun article',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles (${items.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          final quantity = item['quantity'] ?? 0;
          final unitPrice = _toDouble(item['unit_price']);
          final subtotal = _toDouble(item['subtotal']);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  '$quantity',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                item['product_name'] ?? 'Produit',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${unitPrice.toStringAsFixed(2)} DA x $quantity',
              ),
              trailing: Text(
                '${subtotal.toStringAsFixed(2)} DA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique Paiements (${_payments.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ..._payments.map((payment) {
          final amountPaid = _toDouble(payment['amount_paid']);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.payments, color: Colors.white, size: 20),
              ),
              title: Text(
                '${amountPaid.toStringAsFixed(2)} DA',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mode: ${payment['payment_method'] ?? 'N/A'}'),
                  Text('Date: ${_formatDateTime(payment['payment_date'])}'),
                  if (payment['notes'] != null && payment['notes'].toString().isNotEmpty)
                    Text(
                      'Note: ${payment['notes']}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}