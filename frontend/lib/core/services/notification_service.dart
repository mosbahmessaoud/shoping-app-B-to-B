import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const windows = WindowsInitializationSettings(
      appName: 'AB Dental',
      appUserModelId: 'com.iTriDev.medical_shop',
      guid: 'a8c22b1e-728b-4d1a-9c45-fcbf19b7b994',
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
        windows: windows,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }

    _initialized = true;
  }

  Future<void> _requestAndroidPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // You can use a stream or callback to handle navigation
      // Example: NavigationService.navigateFromPayload(payload);
    }
  }

  // Generic notification method
  Future<void> showNotification(
    String title, 
    String body, {
    int? id,
    String? payload,
    NotificationColor? color,
    String? channelId,
    String? channelName,
  }) async {
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    final androidDetails = AndroidNotificationDetails(
      channelId ?? 'default_channel',
      channelName ?? 'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: _getColor(color),
      playSound: true,
      enableVibration: true,
      ticker: title,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const windowsDetails = WindowsNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: windowsDetails,
    );

    await _notifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show notification from admin notification data
  Future<void> showAdminNotification(Map<String, dynamic> notification) async {
    final type = notification['notification_type'] as String?;
    final message = notification['message'] as String? ?? 'Aucun message';
    final id = notification['id'] as int? ?? 0;
    final billId = notification['bill_id'];
    final clientId = notification['client_id'];

    String title;
    String channelId;
    String channelName;
    NotificationColor color;
    String? payload;

    switch (type) {
      case 'new_bill':
        title = '📄 Nouvelle facture';
        channelId = 'bill_channel';
        channelName = 'Factures';
        color = NotificationColor.blue;
        payload = billId != null ? 'bill:$billId' : null;
        break;
      
      case 'low_stock':
        title = '📦 Stock bas';
        channelId = 'stock_channel';
        channelName = 'Stock';
        color = NotificationColor.orange;
        payload = 'stock:$id';
        break;
      
      case 'payment_received':
        title = '💰 Paiement reçu';
        channelId = 'payment_channel';
        channelName = 'Paiements';
        color = NotificationColor.green;
        payload = billId != null ? 'payment:$billId' : null;
        break;
      
      default:
        title = '🔔 Notification';
        channelId = 'general_channel';
        channelName = 'Général';
        color = NotificationColor.grey;
        payload = null;
    }

    await showNotification(
      title,
      message,
      id: id,
      payload: payload,
      color: color,
      channelId: channelId,
      channelName: channelName,
    );
  }

  // Legacy methods (keeping for backward compatibility)
  Future<void> showStockAlert(String productName, int quantity) async {
    await showNotification(
      '📦 Alerte Stock',
      'Stock faible: $productName ($quantity unités)',
      color: NotificationColor.orange,
      channelId: 'stock_channel',
      channelName: 'Stock',
    );
  }

  Future<void> showBillNotification(String billNumber) async {
    await showNotification(
      '📄 Nouvelle Facture',
      'Facture $billNumber créée avec succès',
      color: NotificationColor.blue,
      channelId: 'bill_channel',
      channelName: 'Factures',
    );
  }

  Future<void> showPaymentNotification(String billNumber, double amount) async {
    await showNotification(
      '💰 Paiement Reçu',
      'Paiement de ${amount.toStringAsFixed(2)} DA pour la facture $billNumber',
      color: NotificationColor.green,
      channelId: 'payment_channel',
      channelName: 'Paiements',
    );
  }

  // New helper methods
  Future<void> showNewBillNotification({
    required int billId,
    required String clientName,
    required double amount,
  }) async {
    await showNotification(
      '📄 Nouvelle facture',
      'Facture créée pour $clientName - ${amount.toStringAsFixed(2)} DA',
      payload: 'bill:$billId',
      color: NotificationColor.blue,
      channelId: 'bill_channel',
      channelName: 'Factures',
    );
  }

  Future<void> showLowStockNotification({
    required int productId,
    required String productName,
    required int quantity,
  }) async {
    await showNotification(
      '📦 Stock bas',
      '$productName - Stock restant: $quantity',
      payload: 'product:$productId',
      color: NotificationColor.orange,
      channelId: 'stock_channel',
      channelName: 'Stock',
    );
  }

  Future<void> showPaymentReceivedNotification({
    required int billId,
    required String clientName,
    required double amount,
  }) async {
    await showNotification(
      '💰 Paiement reçu',
      'Paiement de $clientName - ${amount.toStringAsFixed(2)} DA',
      payload: 'bill:$billId',
      color: NotificationColor.green,
      channelId: 'payment_channel',
      channelName: 'Paiements',
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.length;
  }

  // Helper method to get color
  Color? _getColor(NotificationColor? color) {
    switch (color) {
      case NotificationColor.blue:
        return const Color(0xFF2196F3);
      case NotificationColor.orange:
        return const Color(0xFFFF9800);
      case NotificationColor.green:
        return const Color(0xFF4CAF50);
      case NotificationColor.red:
        return const Color(0xFFF44336);
      case NotificationColor.grey:
        return const Color(0xFF9E9E9E);
      default:
        return null;
    }
  }
}

enum NotificationColor {
  blue,
  orange,
  green,
  red,
  grey,
}