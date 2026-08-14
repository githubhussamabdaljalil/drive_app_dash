class QrCodeModel {
  final String code;
  final String status; // active | reset | deleted — confirm exact enum via /meta/statuses
  final String? createdAt;
  final String? invalidatedAt;

  const QrCodeModel({
    required this.code,
    required this.status,
    this.createdAt,
    this.invalidatedAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      code: json['code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString(),
      invalidatedAt: json['invalidated_at']?.toString(),
    );
  }
}
