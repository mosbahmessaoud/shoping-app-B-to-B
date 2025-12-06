import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import 'package:intl/intl.dart';

class ClientNotificationsScreen extends StatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  State<ClientNotificationsScreen> createState() => _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState extends State<ClientNotificationsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _notifications = [];
  bool _loading = true;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final response = await _api.getAllNotifications(
        type: _filterType,
        limit: 50,
      );
      
      setState(() {
        _notifications = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _markAsSent(int id) async {
    try {
      await _api.markNotificationSent(id);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value == 'all' ? null : value;
              });
              _loadNotifications();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Toutes'),
              ),
              const PopupMenuItem(
                value: 'low_stock',
                child: Text('Stock bas'),
              ),
              const PopupMenuItem(
                value: 'bill_overdue',
                child: Text('Factures en retard'),
              ),
              const PopupMenuItem(
                value: 'general',
                child: Text('Général'),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _NotificationCard(
                        notification: _notifications[index],
                        onMarkAsSent: () => _markAsSent(_notifications[index]['id']),
                        onTap: () => _showNotificationDetails(_notifications[index]),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas de notifications pour le moment',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _getNotificationIcon(notification['notification_type']),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getNotificationTitle(notification['notification_type']),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification['message'] ?? 'Aucun message',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: _formatDate(notification['created_at']),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.info_outline,
                label: 'Statut',
                value: (notification['is_sent'] ?? false) ? 'Lu' : 'Non lu',
              ),
            ],
          ),
        ),
        actions: [
          if (!(notification['is_sent'] ?? false))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _markAsSent(notification['id']);
              },
              child: const Text('Marquer comme lu'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Icon _getNotificationIcon(String? type) {
    switch (type) {
      case 'low_stock':
        return const Icon(Icons.inventory_2, color: Colors.orange);
      case 'bill_overdue':
        return const Icon(Icons.warning, color: Colors.red);
      case 'general':
        return const Icon(Icons.info, color: Colors.blue);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  String _getNotificationTitle(String? type) {
    switch (type) {
      case 'low_stock':
        return 'Stock bas';
      case 'bill_overdue':
        return 'Facture en retard';
      case 'general':
        return 'Information';
      default:
        return 'Notification';
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'low_stock':
        return Colors.orange;
      case 'bill_overdue':
        return Colors.red;
      case 'general':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onMarkAsSent;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onMarkAsSent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSent = notification['is_sent'] ?? false;
    final type = notification['notification_type'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSent ? 1 : 3,
      color: isSent ? Colors.grey[50] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _getTypeColor(type).withOpacity(0.1),
                child: _getTypeIcon(type),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getTypeTitle(type),
                            style: TextStyle(
                              fontWeight: isSent ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!isSent)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getTypeColor(type),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['message'] ?? 'Aucun message',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(notification['created_at']),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!isSent)
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: onMarkAsSent,
                  tooltip: 'Marquer comme lu',
                  color: Colors.grey[600],
                  iconSize: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'low_stock':
        return Colors.orange;
      case 'bill_overdue':
        return Colors.red;
      case 'general':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Icon _getTypeIcon(String? type) {
    switch (type) {
      case 'low_stock':
        return const Icon(Icons.inventory_2, color: Colors.orange);
      case 'bill_overdue':
        return const Icon(Icons.warning, color: Colors.red);
      case 'general':
        return const Icon(Icons.info, color: Colors.blue);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  String _getTypeTitle(String? type) {
    switch (type) {
      case 'low_stock':
        return 'Stock bas';
      case 'bill_overdue':
        return 'Facture en retard';
      case 'general':
        return 'Information';
      default:
        return 'Notification';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays}j';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }
}