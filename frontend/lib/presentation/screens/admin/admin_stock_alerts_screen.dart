import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AdminStockAlertsScreen extends StatefulWidget {
  const AdminStockAlertsScreen({super.key});

  @override
  State<AdminStockAlertsScreen> createState() => _AdminStockAlertsScreenState();
}

class _AdminStockAlertsScreenState extends State<AdminStockAlertsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _alerts = [];
  bool _loading = true;
  bool _showResolved = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _loading = true);
    try {
      final response = _showResolved 
          ? await _api.getAllStockAlerts()
          : await _api.getUnresolvedStockAlerts();
      setState(() {
        _alerts = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleResolved(int id, bool isResolved) async {
    try {
      if (isResolved) {
        await _api.unresolveStockAlert(id);
      } else {
        await _api.resolveStockAlert(id);
      }
      _loadAlerts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    final dt = DateTime.parse(date);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  IconData _getAlertIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'low_stock': return Icons.warning;
      case 'out_of_stock': return Icons.error;
      case 'expiring_soon': return Icons.schedule;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes Stock'),
        actions: [
          IconButton(
            icon: Icon(_showResolved ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() => _showResolved = !_showResolved);
              _loadAlerts();
            },
            tooltip: _showResolved ? 'Masquer résolues' : 'Afficher toutes',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: _alerts.isEmpty
                  ? const Center(child: Text('Aucune alerte'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _alerts.length,
                      itemBuilder: (ctx, i) {
                        final alert = _alerts[i];
                        final isResolved = alert['is_resolved'] ?? false;
                        final alertType = alert['alert_type'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isResolved ? Colors.grey : Colors.red,
                              child: Icon(
                                isResolved ? Icons.check : _getAlertIcon(alertType),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(alert['product']?['name'] ?? 'Produit inconnu'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${alert['message'] ?? 'Alerte stock'}'),
                                Text('Type: $alertType'),
                                Text('Stock: ${alert['product']?['quantity_in_stock'] ?? 0} unités'),
                                Text('Seuil min: ${alert['product']?['minimum_stock_level'] ?? 0}'),
                                Text('Créée: ${_formatDate(alert['created_at'])}'),
                                if (alert['resolved_at'] != null)
                                  Text('Résolue: ${_formatDate(alert['resolved_at'])}',
                                    style: const TextStyle(color: Colors.green)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(isResolved ? Icons.refresh : Icons.check_circle),
                              color: isResolved ? Colors.orange : Colors.green,
                              onPressed: () => _toggleResolved(alert['id'], isResolved),
                              tooltip: isResolved ? 'Rouvrir' : 'Résoudre',
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}