import 'dart:math';
import 'package:equatable/equatable.dart';

/// A nearby device discovered via BLE that is broadcasting its GPS location.
class BluetoothPeer extends Equatable {
  final String deviceId;
  final double lat;
  final double lng;

  /// GPS accuracy reported by the peer, in metres.
  final double accuracy;

  /// Speed the peer was travelling at the time of broadcast (km/h).
  final double speedKmh;

  /// When the peer last updated its broadcast.
  final DateTime timestamp;

  /// BLE signal strength – used to estimate physical distance to the peer.
  final int rssi;

  const BluetoothPeer({
    required this.deviceId,
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.speedKmh,
    required this.timestamp,
    required this.rssi,
  });

  /// Location is considered fresh for 2 minutes after the last broadcast.
  bool get isFresh =>
      DateTime.now().difference(timestamp).inSeconds < 120;

  /// Rough distance estimate from RSSI using the log-distance path model.
  /// txPower = -59 dBm (typical BLE at 1 m), path-loss exponent n = 2.
  double get estimatedDistanceMeters {
    const txPower = -59.0;
    const n = 2.0;
    return pow(10.0, (txPower - rssi) / (10.0 * n)).toDouble();
  }

  BluetoothPeer copyWith({int? rssi, DateTime? timestamp}) {
    return BluetoothPeer(
      deviceId: deviceId,
      lat: lat,
      lng: lng,
      accuracy: accuracy,
      speedKmh: speedKmh,
      timestamp: timestamp ?? this.timestamp,
      rssi: rssi ?? this.rssi,
    );
  }

  @override
  List<Object?> get props => [deviceId];
}
