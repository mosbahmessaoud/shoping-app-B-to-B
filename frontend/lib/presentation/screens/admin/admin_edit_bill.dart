import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class AdminEditBillScreen extends StatefulWidget {
  final String billId;
  
  const AdminEditBillScreen({super.key, required this.billId});

  @override
  State<AdminEditBillScreen> createState() => _AdminEditBillScreenState();
}

class _AdminEditBillScreenState extends State<AdminEditBillScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  Map<String, dynamic>? _bill;
  List<dynamic> _payments = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Helper method to safely convert to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
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
      
      // Load bill details (use admin endpoint)
      final billResponse = await _api.getAdminBillById(billId);
      print('✅ Bill response: ${billResponse.data}');
      
      // Load payment history
      List<dynamic> payments = [];
      try {
        final paymentsResponse = await _api.getBillPaymentHistory(billId);
        payments = paymentsResponse.data ?? [];
        print('✅ Payments response: $payments');
      } catch (e) {
        print('⚠️ No payments found: $e');
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

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final remaining = _toDouble(_bill!['total_remaining']);
    if (amount > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le montant ne peut pas dépasser le reste à payer (${remaining.toStringAsFixed(2)} DA)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final billId = int.parse(widget.billId);
      
      print('💰 Submitting payment: billId=$billId, amount=$amount');
      
      // Use the payBill endpoint with query parameter
      final response = await _api.payBill(billId, amount);
      
      print('✅ Payment response: ${response.data}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement enregistré avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear form and reload
      _amountController.clear();
      await _loadBillDetails();
      
    } catch (e) {
      print('❌ Error submitting payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.amber;
      case 'unpaid':
      case 'not paid': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'paid': return 'Payée';
      case 'partial': return 'Paiement Partiel';
      case 'unpaid':
      case 'not paid': return 'Impayée';
      default: return 'Inconnu';
    }
  }

  // Determine status based on payment amounts
  String _calculateStatus(double totalPaid, double remaining) {
    if (remaining == 0.0 && totalPaid > 0.0) {
      return 'paid'; // Fully paid
    } else if (totalPaid > 0.0 && remaining > 0.0) {
      return 'partial'; // Partially paid
    } else {
      return 'not paid'; // Unpaid
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cash': return 'Espèces';
      case 'credit_card': return 'Carte de crédit';
      case 'bank_transfer': return 'Virement bancaire';
      case 'check': return 'Chèque';
      case 'other': return 'Autre';
      default: return method;
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
    final totalAmount = _toDouble(_bill!['total_amount']);
    final totalPaid = _toDouble(_bill!['total_paid']);
    final remaining = _toDouble(_bill!['total_remaining']);
    
    // Calculate actual status based on payment amounts
    final actualStatus = _calculateStatus(totalPaid, remaining);
    final isPaid = actualStatus == 'paid';

    return Scaffold(
      appBar: AppBar(
        title: Text('Facture #${_bill!['bill_number'] ?? widget.billId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBillDetails,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBillDetails,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            _buildStatusCard(actualStatus),
            const SizedBox(height: 16),
            
            // Client Info Card
            _buildClientInfoCard(),
            const SizedBox(height: 16),
            
            // Financial Summary Card
            _buildFinancialSummaryCard(totalAmount, totalPaid, remaining),
            const SizedBox(height: 16),
            
            // Items Section
            _buildItemsSection(items),
            const SizedBox(height: 16),
            
            // Payment Form (only if not fully paid)
            if (!isPaid) _buildPaymentForm(remaining),
            
            // Payment History
            if (_payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPaymentsSection(),
            ],
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
              status == 'partial' ? Icons.schedule : Icons.cancel,
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

  Widget _buildClientInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations Client',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person,
              label: 'Nom',
              value: _bill!['client_name'] ?? 'N/A',
            ),
            const Divider(),
            _InfoRow(
              icon: Icons.email,
              label: 'Email',
              value: _bill!['client_email'] ?? 'N/A',
            ),
            const Divider(),
            _InfoRow(
              icon: Icons.phone,
              label: 'Téléphone',
              value: _bill!['client_phone'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(double totalAmount, double totalPaid, double remaining) {
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

  Widget _buildPaymentForm(double remaining) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Enregistrer un Paiement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Montant *',
                  hintText: 'Ex: ${remaining.toStringAsFixed(2)}',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'DA',
                  border: const OutlineInputBorder(),
                  helperText: 'Reste à payer: ${remaining.toStringAsFixed(2)} DA',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Montant invalide';
                  }
                  if (amount > remaining) {
                    return 'Montant supérieur au reste à payer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Quick amount buttons
              Wrap(
                spacing: 8,
                children: [
                  if (remaining >= 100)
                    FilledButton.tonal(
                      onPressed: () => _amountController.text = '100',
                      child: const Text('100 DA'),
                    ),
                  if (remaining >= 500)
                    FilledButton.tonal(
                      onPressed: () => _amountController.text = '500',
                      child: const Text('500 DA'),
                    ),
                  if (remaining >= 1000)
                    FilledButton.tonal(
                      onPressed: () => _amountController.text = '1000',
                      child: const Text('1000 DA'),
                    ),
                  FilledButton.tonal(
                    onPressed: () => _amountController.text = remaining.toStringAsFixed(2),
                    child: const Text('Tout payer'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submitPayment,
                  icon: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_submitting ? 'Enregistrement...' : 'Enregistrer le Paiement'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                  Text('Mode: ${_getPaymentMethodLabel(payment['payment_method'] ?? 'N/A')}'),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
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