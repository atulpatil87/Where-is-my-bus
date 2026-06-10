import 'package:equatable/equatable.dart';

/// Auth response from PMPML OTP verify endpoint.
class PmpmlAuthModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String mobile;
  final String? userId;
  final String? deviceId;

  const PmpmlAuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.mobile,
    this.userId,
    this.deviceId,
  });

  factory PmpmlAuthModel.fromJson(Map<String, dynamic> json) => PmpmlAuthModel(
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
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'mobile': mobile,
        if (userId != null) 'user_id': userId,
        if (deviceId != null) 'device_id': deviceId,
      };

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  @override
  List<Object?> get props => [accessToken, refreshToken, mobile, userId];
}
