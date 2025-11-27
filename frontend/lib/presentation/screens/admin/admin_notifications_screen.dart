import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getAllNotifications();
      setState(() {
        _notifications = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendPending() async {
    try {
      await _api.sendPendingNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications envoyées avec succès')),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _markSent(int id) async {
    await _api.markNotificationSent(id);
    _loadNotifications();
  }

  Future<void> _deleteNotification(int id) async {
    await _api.deleteNotification(id);
    _loadNotifications();
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    final dt = DateTime.parse(date);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'stock_alert': return Icons.inventory_2;
      case 'bill_created': return Icons.receipt_long;
      case 'payment_received': return Icons.payments;
      case 'low_stock': return Icons.warning;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'stock_alert': case 'low_stock': return Colors.orange;
      case 'bill_created': return Colors.blue;
      case 'payment_received': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getChannelLabel(String? channel) {
    switch (channel?.toLowerCase()) {
      case 'email': return '📧 Email';
      case 'sms': return '📱 SMS';
      case 'push': return '🔔 Push';
      case 'in_app': return '📲 In-App';
      default: return channel ?? 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendPending,
            tooltip: 'Envoyer en attente',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? const Center(child: Text('Aucune notification'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (ctx, i) {
                        final notif = _notifications[i];
                        final isSent = notif['is_sent'] ?? false;
                        final type = notif['notification_type'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSent ? Colors.green : _getIconColor(type),
                              child: Icon(_getIcon(type), color: Colors.white),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(type ?? 'Notification')),
                                Chip(
                                  label: Text(_getChannelLabel(notif['channel'])),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif['message'] ?? 'Pas de message',
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                                if (notif['bill_id'] != null)
                                  Text('Facture #${notif['bill']?['bill_number'] ?? notif['bill_id']}'),
                                if (notif['client_id'] != null)
                                  Text('Client: ${notif['client']?['username'] ?? 'N/A'}'),
                                Text('Créée: ${_formatDate(notif['created_at'])}'),
                                if (notif['sent_at'] != null)
                                  Text('Envoyée: ${_formatDate(notif['sent_at'])}',
                                    style: const TextStyle(color: Colors.green)),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (ctx) => [
                                if (!isSent)
                                  PopupMenuItem(
                                    value: 'mark',
                                    child: const Row(children: [
                                      Icon(Icons.check_circle), 
                                      SizedBox(width: 8), 
                                      Text('Marquer envoyé')
                                    ]),
                                  ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: const Row(children: [
                                    Icon(Icons.delete, color: Colors.red), 
                                    SizedBox(width: 8), 
                                    Text('Supprimer')
                                  ]),
                                ),
                              ],
                              onSelected: (val) {
                                if (val == 'mark') _markSent(notif['id']);
                                if (val == 'delete') _deleteNotification(notif['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}