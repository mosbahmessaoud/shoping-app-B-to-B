// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/services/api_service.dart';
// import '../../widgets/theme_toggle_button.dart';

// class AdminNotificationsScreen extends StatefulWidget {
//   const AdminNotificationsScreen({super.key});

//   @override
//   State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
// }

// class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
//   final ApiService _api = ApiService();
//   List<dynamic> _notifications = [];
//   bool _loading = true;
//   String _filter = 'all'; // all, read, unread

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   Future<void> _loadNotifications() async {
//     setState(() => _loading = true);
//     try {
//       final response = await _api.getAllNotifications();
//       setState(() {
//         _notifications = response.data;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur de chargement: ${e.toString()}'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _markAsRead(int notificationId) async {
//     // try {
//     //   await _api.markNotificationAsRead(notificationId);
//     //   _loadNotifications();
//     // } catch (e) {
//     //   if (mounted) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(
//     //         content: Text('Erreur: ${e.toString()}'),
//     //         backgroundColor: Theme.of(context).colorScheme.error,
//     //       ),
//     //     );
//     //   }
//     // }
//   }

//   Future<void> _markAllAsRead() async {
//     // try {
//     //   await _api.markAllNotificationsAsRead();
//     //   _loadNotifications();
//     //   if (mounted) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(
//     //         content: const Text('Toutes les notifications marquées comme lues'),
//     //         backgroundColor: Theme.of(context).colorScheme.primary,
//     //       ),
//     //     );
//     //   }
//     // } catch (e) {
//     //   if (mounted) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(
//     //         content: Text('Erreur: ${e.toString()}'),
//     //         backgroundColor: Theme.of(context).colorScheme.error,
//     //       ),
//     //     );
//     //   }
//     // }
//   }

//   Future<void> _deleteNotification(int notificationId) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirmation'),
//         content: const Text('Voulez-vous vraiment supprimer cette notification?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.error,
//             ),
//             child: const Text('Supprimer'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await _api.deleteNotification(notificationId);
//         _loadNotifications();
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Erreur: ${e.toString()}'),
//               backgroundColor: Theme.of(context).colorScheme.error,
//             ),
//           );
//         }
//       }
//     }
//   }

//   List<dynamic> get _filteredNotifications {
//     if (_filter == 'read') {
//       return _notifications.where((n) => n['is_read'] == true).toList();
//     } else if (_filter == 'unread') {
//       return _notifications.where((n) => n['is_read'] == false).toList();
//     }
//     return _notifications;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         actions: [
//           const ThemeToggleButton(),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.filter_list),
//             onSelected: (value) {
//               setState(() => _filter = value);
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'all',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.all_inbox,
//                       color: _filter == 'all' ? theme.colorScheme.primary : null,
//                     ),
//                     const SizedBox(width: 8),
//                     const Text('Toutes'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'unread',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.mark_email_unread,
//                       color: _filter == 'unread' ? theme.colorScheme.primary : null,
//                     ),
//                     const SizedBox(width: 8),
//                     const Text('Non lues'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'read',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.mark_email_read,
//                       color: _filter == 'read' ? theme.colorScheme.primary : null,
//                     ),
//                     const SizedBox(width: 8),
//                     const Text('Lues'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.done_all),
//             onPressed: _markAllAsRead,
//             tooltip: 'Tout marquer comme lu',
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadNotifications,
//             tooltip: 'Actualiser',
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadNotifications,
//               child: _filteredNotifications.isEmpty
//                   ? _buildEmptyState()
//                   : ListView.builder(
//                       itemCount: _filteredNotifications.length,
//                       padding: const EdgeInsets.all(8),
//                       itemBuilder: (context, index) {
//                         final notification = _filteredNotifications[index];
//                         final isUnread = notification['is_read'] == false;
                        
//                         return Card(
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           color: isUnread
//                               ? (isDark
//                                   ? theme.colorScheme.primaryContainer.withOpacity(0.3)
//                                   : theme.colorScheme.primaryContainer.withOpacity(0.2))
//                               : null,
//                           child: Dismissible(
//                             key: Key('notification_${notification['id']}'),
//                             background: Container(
//                               color: theme.colorScheme.primary,
//                               alignment: Alignment.centerLeft,
//                               padding: const EdgeInsets.only(left: 20),
//                               child: const Icon(
//                                 Icons.mark_email_read,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             secondaryBackground: Container(
//                               color: theme.colorScheme.error,
//                               alignment: Alignment.centerRight,
//                               padding: const EdgeInsets.only(right: 20),
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             confirmDismiss: (direction) async {
//                               if (direction == DismissDirection.startToEnd) {
//                                 _markAsRead(notification['id']);
//                                 return false;
//                               } else {
//                                 return true;
//                               }
//                             },
//                             onDismissed: (direction) {
//                               if (direction == DismissDirection.endToStart) {
//                                 _deleteNotification(notification['id']);
//                               }
//                             },
//                             child: ListTile(
//                               leading: _buildNotificationIcon(
//                                 notification['type'],
//                                 isUnread,
//                                 theme,
//                               ),
//                               title: Text(
//                                 notification['title'] ?? 'Notification',
//                                 style: TextStyle(
//                                   fontWeight: isUnread
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(height: 4),
//                                   Text(notification['message'] ?? ''),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     _formatDate(notification['created_at']),
//                                     style: theme.textTheme.bodySmall?.copyWith(
//                                       color: isDark
//                                           ? Colors.grey[400]
//                                           : Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               trailing: PopupMenuButton(
//                                 itemBuilder: (context) => [
//                                   if (isUnread)
//                                     PopupMenuItem(
//                                       child: const Row(
//                                         children: [
//                                           Icon(Icons.mark_email_read),
//                                           SizedBox(width: 8),
//                                           Text('Marquer comme lu'),
//                                         ],
//                                       ),
//                                       onTap: () {
//                                         Future.delayed(
//                                           Duration.zero,
//                                           () => _markAsRead(notification['id']),
//                                         );
//                                       },
//                                     ),
//                                   PopupMenuItem(
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.delete,
//                                           color: theme.colorScheme.error,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           'Supprimer',
//                                           style: TextStyle(
//                                             color: theme.colorScheme.error,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     onTap: () {
//                                       Future.delayed(
//                                         Duration.zero,
//                                         () => _deleteNotification(notification['id']),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               onTap: () {
//                                 if (isUnread) {
//                                   _markAsRead(notification['id']);
//                                 }
//                                 _showNotificationDetails(notification);
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//     );
//   }

//   Widget _buildNotificationIcon(String? type, bool isUnread, ThemeData theme) {
//     IconData icon;
//     Color color;

//     switch (type) {
//       case 'stock_alert':
//         icon = Icons.warning;
//         color = Colors.orange;
//         break;
//       case 'low_stock':
//         icon = Icons.trending_down;
//         color = Colors.red;
//         break;
//       case 'bill':
//         icon = Icons.receipt_long;
//         color = Colors.blue;
//         break;
//       case 'payment':
//         icon = Icons.payments;
//         color = Colors.green;
//         break;
//       default:
//         icon = Icons.notifications;
//         color = theme.colorScheme.primary;
//     }

//     return CircleAvatar(
//       backgroundColor: isUnread
//           ? color
//           : (theme.brightness == Brightness.dark
//               ? Colors.grey[700]
//               : Colors.grey[300]),
//       child: Icon(
//         icon,
//         color: isUnread ? Colors.white : color,
//         size: 20,
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             _filter == 'unread'
//                 ? Icons.mark_email_read
//                 : Icons.notifications_none,
//             size: 80,
//             color: isDark ? Colors.grey[600] : Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _filter == 'unread'
//                 ? 'Aucune notification non lue'
//                 : _filter == 'read'
//                     ? 'Aucune notification lue'
//                     : 'Aucune notification',
//             style: theme.textTheme.titleLarge?.copyWith(
//               color: isDark ? Colors.grey[400] : Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Vous êtes à jour!',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: isDark ? Colors.grey[500] : Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showNotificationDetails(Map<String, dynamic> notification) {
//     final theme = Theme.of(context);
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             _buildNotificationIcon(
//               notification['type'],
//               notification['is_read'] == false,
//               theme,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(notification['title'] ?? 'Notification'),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(notification['message'] ?? ''),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: theme.brightness == Brightness.dark
//                       ? theme.colorScheme.surfaceContainerHighest
//                       : theme.colorScheme.surfaceContainerLow,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.access_time,
//                           size: 16,
//                           color: theme.textTheme.bodySmall?.color,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _formatDate(notification['created_at']),
//                           style: theme.textTheme.bodySmall,
//                         ),
//                       ],
//                     ),
//                     if (notification['type'] != null) ...[
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.category,
//                             size: 16,
//                             color: theme.textTheme.bodySmall?.color,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             _formatType(notification['type']),
//                             style: theme.textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ],
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
//         ],
//       ),
//     );
//   }

//   String _formatDate(String? dateStr) {
//     if (dateStr == null) return '';
//     try {
//       final date = DateTime.parse(dateStr);
//       final now = DateTime.now();
//       final difference = now.difference(date);

//       if (difference.inMinutes < 1) {
//         return 'À l\'instant';
//       } else if (difference.inHours < 1) {
//         return 'Il y a ${difference.inMinutes} min';
//       } else if (difference.inDays < 1) {
//         return 'Il y a ${difference.inHours}h';
//       } else if (difference.inDays < 7) {
//         return 'Il y a ${difference.inDays}j';
//       } else {
//         return '${date.day}/${date.month}/${date.year}';
//       }
//     } catch (e) {
//       return dateStr;
//     }
//   }

//   String _formatType(String type) {
//     switch (type) {
//       case 'stock_alert':
//         return 'Alerte de stock';
//       case 'low_stock':
//         return 'Stock faible';
//       case 'bill':
//         return 'Facture';
//       case 'payment':
//         return 'Paiement';
//       default:
//         return type;
//     }
//   }
// }