import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const windows = WindowsInitializationSettings(
      appName: 'medical shop',
      appUserModelId: 'com.iTriDev.medical_shop',
      guid: 'a8c22b1e-728b-4d1a-9c45-fcbf19b7b994', // Generate a unique GUID for your app
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
        windows: windows,
      ),
    );
  }

  Future<void> showNotification(String title, String body) async {
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
    );
  }

  Future<void> showStockAlert(String productName, int quantity) async {
    await showNotification(
      'Alerte Stock',
      'Stock faible: $productName ($quantity unités)',
    );
  }

  Future<void> showBillNotification(String billNumber) async {
    await showNotification(
      'Nouvelle Facture',
      'Facture $billNumber créée avec succès',
    );
  }

  Future<void> showPaymentNotification(String billNumber, double amount) async {
    await showNotification(
      'Paiement Reçu',
      'Paiement de $amount DA pour la facture $billNumber',
    );
  }
}