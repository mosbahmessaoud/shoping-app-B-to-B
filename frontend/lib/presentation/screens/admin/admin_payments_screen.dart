import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getAllPayments();
      setState(() {
        _payments = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    final dt = DateTime.parse(date);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color _getMethodColor(String? method) {
    switch (method?.toLowerCase()) {
      case 'cash': return Colors.green;
      case 'credit_card': return Colors.blue;
      case 'bank_transfer': return Colors.purple;
      case 'check': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getMethodLabel(String? method) {
    switch (method?.toLowerCase()) {
      case 'cash': return 'Espèces';
      case 'credit_card': return 'Carte';
      case 'bank_transfer': return 'Virement';
      case 'check': return 'Chèque';
      default: return method ?? 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPayments,
              child: _payments.isEmpty
                  ? const Center(child: Text('Aucun paiement'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _payments.length,
                      itemBuilder: (ctx, i) {
                        final payment = _payments[i];
                        final method = payment['payment_method'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getMethodColor(method),
                              child: const Icon(Icons.payments, color: Colors.white),
                            ),
                            title: Text('${payment['amount_paid']} DA', 
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Facture: ${payment['bill']?['bill_number'] ?? 'N/A'}'),
                                Text('Client: ${payment['bill']?['client']?['username'] ?? 'N/A'}'),
                                Text('Date: ${_formatDate(payment['payment_date'])}'),
                                if (payment['notes'] != null && payment['notes'].toString().isNotEmpty)
                                  Text('Note: ${payment['notes']}', 
                                    style: const TextStyle(fontStyle: FontStyle.italic)),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(_getMethodLabel(method)),
                              backgroundColor: _getMethodColor(method).withOpacity(0.2),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}