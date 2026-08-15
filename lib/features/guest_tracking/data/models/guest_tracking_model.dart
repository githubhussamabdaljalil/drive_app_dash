class GuestTrackingModel {
  final GuestVehicleModel vehicle;
  final GuestLocationModel? location;
  final String? expiresAt;
  final String? liveChannel;

  const GuestTrackingModel({
    required this.vehicle,
    this.location,
    this.expiresAt,
    this.liveChannel,
  });

  factory GuestTrackingModel.fromJson(Map<String, dynamic> json) {
    return GuestTrackingModel(
      vehicle: GuestVehicleModel.fromJson(
        Map<String, dynamic>.from(json['vehicle'] ?? {}),
      ),
      location: json['location'] == null
          ? null
          : GuestLocationModel.fromJson(
              Map<String, dynamic>.from(json['location']),
            ),
      expiresAt: json['expires_at']?.toString(),
      liveChannel: json['live_channel']?.toString(),
    );
  }

  GuestTrackingModel copyWithLocation(GuestLocationModel location) {
    return GuestTrackingModel(
      vehicle: vehicle,
      location: location,
      expiresAt: expiresAt,
      liveChannel: liveChannel,
    );
  }
}

class GuestVehicleModel {
  final String plateNo;
  final String type;
  final String model;

  const GuestVehicleModel({
    required this.plateNo,
    required this.type,
    required this.model,
  });

  factory GuestVehicleModel.fromJson(Map<String, dynamic> json) {
    return GuestVehicleModel(
      plateNo: json['plate_no']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
    );
  }
}

class GuestLocationModel {
  final double lat;
  final double lng;
  final String? at;

  const GuestLocationModel({
    required this.lat,
    required this.lng,
    this.at,
  });

  factory GuestLocationModel.fromJson(Map<String, dynamic> json) {
    return GuestLocationModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      at: json['at']?.toString(),
    );
  }
}
