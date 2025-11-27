class Notification {
  final int id;
  final int? adminId;
  final int? clientId;
  final int? billId;
  final int? stockAlertId;
  final String notificationType;
  final String channel;
  final String message;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime createdAt;

  Notification({
    required this.id,
    this.adminId,
    this.clientId,
    this.billId,
    this.stockAlertId,
    required this.notificationType,
    required this.channel,
    required this.message,
    required this.isSent,
    this.sentAt,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['id'],
        adminId: json['admin_id'],
        clientId: json['client_id'],
        billId: json['bill_id'],
        stockAlertId: json['stock_alert_id'],
        notificationType: json['notification_type'],
        channel: json['channel'],
        message: json['message'],
        isSent: json['is_sent'] ?? false,
        sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'admin_id': adminId,
        'client_id': clientId,
        'bill_id': billId,
        'stock_alert_id': stockAlertId,
        'notification_type': notificationType,
        'channel': channel,
        'message': message,
        'is_sent': isSent,
        'sent_at': sentAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

class NotificationSummary {
  final int totalNotifications;
  final int sentNotifications;
  final int pendingNotifications;
  final int emailNotifications;
  final int whatsappNotifications;

  NotificationSummary({
    required this.totalNotifications,
    required this.sentNotifications,
    required this.pendingNotifications,
    required this.emailNotifications,
    required this.whatsappNotifications,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) =>
      NotificationSummary(
        totalNotifications: json['total_notifications'],
        sentNotifications: json['sent_notifications'],
        pendingNotifications: json['pending_notifications'],
        emailNotifications: json['email_notifications'],
        whatsappNotifications: json['whatsapp_notifications'],
      );
}