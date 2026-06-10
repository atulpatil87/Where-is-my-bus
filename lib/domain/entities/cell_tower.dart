import 'package:equatable/equatable.dart';

/// A single serving cell read from the device modem (no GPS involved).
///
/// This is the raw radio observation — the same data "Where is my Train" reads
/// to place a train on the network without a satellite fix.
class CellTower extends Equatable {
  final String radioType; // lte | gsm | wcdma | cdma | nr
  final String mcc; // mobile country code
  final String mnc; // mobile network code
  final int? lac; // location area code (tac on LTE/NR)
  final int? cid; // cell id (ci/nci/cid)
  final int? pci; // physical cell id, for tie-breaking
  final int signalDbm; // signal strength, less-negative = stronger
  final bool isRegistered; // true for the cell the phone is camped on

  const CellTower({
    required this.radioType,
    required this.mcc,
    required this.mnc,
    required this.lac,
    required this.cid,
    required this.pci,
    required this.signalDbm,
    required this.isRegistered,
  });

  /// Stable identity for this tower, used as the fingerprint database key.
  /// Two devices on the same physical cell produce the same key.
  String get cellKey => '${radioType}_${mcc}_${mnc}_${lac ?? 'x'}_${cid ?? 'x'}';

  /// A tower is usable for positioning only if it has both a cell id and area.
  bool get isValid => cid != null && lac != null;

  @override
  List<Object?> get props => [radioType, mcc, mnc, lac, cid];
}

/// A crowd-learned mapping from a [CellTower] (by [cellKey]) to a real-world
/// location and the nearest bus stop. Built up over time from rider samples.
class TowerFingerprint extends Equatable {
  final String cellKey;
  final double lat;
  final double lng;
  final String nearestStopId;
  final String nearestStopName;
  final int sampleCount;
  final DateTime lastUpdated;

  const TowerFingerprint({
    required this.cellKey,
    required this.lat,
    required this.lng,
    required this.nearestStopId,
    required this.nearestStopName,
    required this.sampleCount,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [cellKey];
}

/// The result of resolving the current serving tower into a position, ready to
/// drive the map or a shared bus location — with no satellite fix used.
class TowerFix extends Equatable {
  final CellTower tower;
  final TowerFingerprint fingerprint;

  const TowerFix({required this.tower, required this.fingerprint});

  double get lat => fingerprint.lat;
  double get lng => fingerprint.lng;
  String get nearestStopName => fingerprint.nearestStopName;
  String get nearestStopId => fingerprint.nearestStopId;

  /// Confidence grows with the number of crowd samples behind the fingerprint.
  bool get isTrusted => fingerprint.sampleCount >= 3;

  @override
  List<Object?> get props => [tower, fingerprint];
}
