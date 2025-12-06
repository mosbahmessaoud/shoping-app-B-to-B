import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class BackgroundNotificationService {
  static const String _lastCheckedKey = 'last_notification_check';
  static const String _sentNotificationsKey = 'sent_notifications';

  /// Check for new notifications and send them
  static Future<void> checkAndSendNotifications() async {
    try {
      // Get token
      final storage = StorageService();
      final token = await storage.getToken();
      
      if (token == null) {
        print('No auth token found, skipping notification check');
        return;
      }

      // Get user type
      final userType = await storage.getUserType();
      
      // Only check for admin users
      if (userType != 'admin') {
        print('Not an admin user, skipping notification check');
        return;
      }

      final api = ApiService();
      final notificationService = NotificationService();
      
      // Initialize notification service
      await notificationService.initialize();

      // Get unsent notifications
      final response = await api.getAllNotificationsAdmin(
        isSent: false,
        limit: 20,
      );

      final notifications = response.data as List;
      
      if (notifications.isEmpty) {
        print('No new notifications to send');
        return;
      }

      // Get list of already sent notification IDs
      final sentIds = await _getSentNotificationIds();
      
      int sentCount = 0;
      for (var notification in notifications) {
        final id = notification['id'];
        
        // Skip if already sent locally
        if (sentIds.contains(id)) {
          continue;
        }
        
        try {
          // Send system notification
          await notificationService.showAdminNotification(notification);
          
          // Mark as sent in backend
          await api.markNotificationSent(id);
          
          // Save locally as sent
          await _addSentNotificationId(id);
          
          sentCount++;
        } catch (e) {
          print('Error sending notification $id: $e');
        }
      }

      print('Sent $sentCount new notifications');
      
      // Update last checked timestamp
      await _updateLastChecked();
      
    } catch (e) {
      print('Error in background notification check: $e');
    }
  }

  /// Get list of already sent notification IDs
  static Future<Set<int>> _getSentNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentList = prefs.getStringList(_sentNotificationsKey) ?? [];
      return sentList.map((e) => int.parse(e)).toSet();
    } catch (e) {
      return {};
    }
  }

  /// Add a notification ID to the sent list
  static Future<void> _addSentNotificationId(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentIds = await _getSentNotificationIds();
      sentIds.add(id);
      
      // Keep only last 100 IDs to prevent storage bloat
      final limitedIds = sentIds.take(100).toList();
      await prefs.setStringList(
        _sentNotificationsKey,
        limitedIds.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      print('Error saving sent notification ID: $e');
    }
  }

  /// Update last checked timestamp
  static Future<void> _updateLastChecked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckedKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error updating last checked: $e');
    }
  }

  /// Get last checked timestamp
  static Future<DateTime?> getLastChecked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastCheckedKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      print('Error getting last checked: $e');
    }
    return null;
  }

  /// Clear sent notifications history (for testing)
  static Future<void> clearSentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sentNotificationsKey);
      await prefs.remove(_lastCheckedKey);
    } catch (e) {
      print('Error clearing sent history: $e');
    }
  }
}