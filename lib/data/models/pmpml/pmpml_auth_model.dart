import 'package:equatable/equatable.dart';

/// Auth response from PMPML OTP verify endpoint.
class PmpmlAuthModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String mobile;
  final String? userId;
  final String? deviceId;

  /// Access-token lifetime in seconds, if the backend reports it. Used to
  /// decide when to silently refresh instead of forcing a fresh OTP login.
  final int? expiresInSeconds;

  const PmpmlAuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.mobile,
    this.userId,
    this.deviceId,
    this.expiresInSeconds,
  });

  factory PmpmlAuthModel.fromJson(Map<String, dynamic> json) {
    int? parseExpiry(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return PmpmlAuthModel(
      accessToken: (json['access_token'] ??
              json['accessToken'] ??
              json['token'] ??
              '') as String,
      refreshToken: (json['refresh_token'] ??
              json['refreshToken'] ??
              json['refresh'] ??
              '') as String,
      mobile: (json['mobile'] ?? json['mobile_number'] ?? '') as String,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
      deviceId: json['device_id'] as String?,
      expiresInSeconds: parseExpiry(
          json['expires_in'] ?? json['expiresIn'] ?? json['expiry']),
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'mobile': mobile,
        if (userId != null) 'user_id': userId,
        if (deviceId != null) 'device_id': deviceId,
        if (expiresInSeconds != null) 'expires_in': expiresInSeconds,
      };

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  @override
  List<Object?> get props => [accessToken, refreshToken, mobile, userId];
}
