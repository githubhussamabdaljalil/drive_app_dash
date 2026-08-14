class ManagerNotificationModel {
  final int id;
  final String type; // currently only "company_expiry"
  final String? event; // payload.event: "expiring_soon" | "expired"
  final Map<String, dynamic> payload;
  final String? readAt;
  final String? createdAt;

  const ManagerNotificationModel({
    required this.id,
    required this.type,
    this.event,
    required this.payload,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  factory ManagerNotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = (json['payload'] as Map?)?.cast<String, dynamic>() ?? {};
    return ManagerNotificationModel(
      id: json['id'] ?? 0,
      type: json['type']?.toString() ?? '',
      event: payload['event']?.toString(),
      payload: payload,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
