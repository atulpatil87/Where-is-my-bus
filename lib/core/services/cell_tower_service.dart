import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/entities/cell_tower.dart';

/// Bridges to the native [MainActivity] MethodChannel that reads the device's
/// serving cell towers. This is the no-GPS positioning primitive — it asks the
/// modem which tower it is camped on, exactly like "Where is my Train".
class CellTowerService {
  static const MethodChannel _channel = MethodChannel('com.busindia/cell_tower');

  /// True on platforms that expose cell info (Android). iOS has no public API
  /// for serving-cell identity, so callers should fall back gracefully.
  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> hasPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Triggers the runtime permission dialog and returns the post-prompt state.
  Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Reads all visible serving cells. Throws [CellTowerException] on failure so
  /// callers can map it to a typed Failure.
  Future<List<CellTower>> getServingCells() async {
    try {
      final raw =
          await _channel.invokeMethod<List<dynamic>>('getServingCells') ?? [];
      return raw
          .map((e) => _fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on PlatformException catch (e) {
      throw CellTowerException(e.code, e.message ?? 'Cell read failed');
    } on MissingPluginException {
      throw const CellTowerException('UNSUPPORTED', 'Cell info unavailable');
    }
  }

  /// Returns the registered cell with the strongest signal — the one the phone
  /// is actively using and therefore the best position estimate.
  Future<CellTower?> getPrimaryCell() async {
    final cells = await getServingCells();
    final usable = cells.where((c) => c.isValid).toList();
    if (usable.isEmpty) return null;
    usable.sort((a, b) {
      if (a.isRegistered != b.isRegistered) return a.isRegistered ? -1 : 1;
      return b.signalDbm.compareTo(a.signalDbm); // less negative first
    });
    return usable.first;
  }

  /// Emits the primary serving cell every [interval]. Drives the live readout.
  Stream<CellTower?> watchPrimaryCell({
    Duration interval = const Duration(seconds: 8),
  }) async* {
    yield await getPrimaryCell();
    yield* Stream.periodic(interval).asyncMap((_) => getPrimaryCell());
  }

  CellTower _fromMap(Map<String, dynamic> m) {
    return CellTower(
      radioType: m['radioType'] as String? ?? 'unknown',
      mcc: m['mcc']?.toString() ?? '',
      mnc: m['mnc']?.toString() ?? '',
      lac: (m['lac'] as num?)?.toInt(),
      cid: (m['cid'] as num?)?.toInt(),
      pci: (m['pci'] as num?)?.toInt(),
      signalDbm: (m['signalDbm'] as num?)?.toInt() ?? -120,
      isRegistered: m['isRegistered'] as bool? ?? false,
    );
  }
}

class CellTowerException implements Exception {
  final String code;
  final String message;
  const CellTowerException(this.code, this.message);

  @override
  String toString() => 'CellTowerException($code): $message';
}
