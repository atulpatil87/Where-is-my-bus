import 'dart:async';
import 'dart:typed_data';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import '../../domain/entities/bluetooth_peer.dart';

/// BitChat-style Bluetooth Low Energy location mesh.
///
/// Each device does two things simultaneously:
///   1. **Advertises** its own GPS location in the BLE manufacturer data.
///   2. **Scans** for other BusIndia devices and collects their locations.
///
/// When GPS is unavailable this service provides a fallback coordinate
/// derived from the closest peer using RSSI-based distance estimation.
class BluetoothLocationService {
  // Custom 128-bit service UUID that identifies BusIndia BLE packets.
  static final UUID _serviceUUID = UUID.fromString(
    'A1B2C3D4-E5F6-7890-ABCD-EF1234567890',
  );

  // Hypothetical manufacturer ID (0xFFFF = testing/unregistered).
  static const int _manufacturerId = 0xFFFF;

  // Stale peer cutoff: 2 minutes.
  static const _staleDuration = Duration(minutes: 2);

  final CentralManager _central = CentralManager.instance;
  final PeripheralManager _peripheral = PeripheralManager.instance;

  final _peersController =
      StreamController<List<BluetoothPeer>>.broadcast();
  final Map<String, BluetoothPeer> _peers = {};

  StreamSubscription<DiscoveredEventArgs>? _discoverySubscription;

  bool _isScanning = false;
  bool _isAdvertising = false;

  /// Live stream of discovered peers. Emits on every update.
  Stream<List<BluetoothPeer>> get peersStream => _peersController.stream;

  /// Snapshot of currently known (and fresh) peers.
  List<BluetoothPeer> get currentPeers {
    _evictStalePeers();
    return List.unmodifiable(_peers.values.toList());
  }

  bool get isScanning => _isScanning;
  bool get isAdvertising => _isAdvertising;

  // ── Advertising (share own location) ────────────────────────────────────────

  /// Start BLE advertising with [lat], [lng], [accuracy] (m), [speedKmh].
  /// Returns `true` if advertising started successfully.
  Future<bool> startAdvertising({
    required double lat,
    required double lng,
    required double accuracy,
    required double speedKmh,
  }) async {
    try {
      final authorized = await _peripheral.authorize();
      if (!authorized) return false;
      if (_peripheral.state != BluetoothLowEnergyState.poweredOn) return false;

      if (_isAdvertising) await stopAdvertising();

      await _peripheral.startAdvertising(
        Advertisement(
          name: 'BusIndia',
          serviceUUIDs: [_serviceUUID],
          manufacturerSpecificData: [
            ManufacturerSpecificData(
              id: _manufacturerId,
              data: _encode(lat: lat, lng: lng, accuracy: accuracy, speedKmh: speedKmh),
            ),
          ],
        ),
      );
      _isAdvertising = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Update the advertised location without restarting the peripheral.
  Future<void> updateAdvertisedLocation({
    required double lat,
    required double lng,
    required double accuracy,
    required double speedKmh,
  }) async {
    if (!_isAdvertising) return;
    // Stop and restart with new data — BLE stack requires this for most platforms.
    await stopAdvertising();
    await startAdvertising(
      lat: lat,
      lng: lng,
      accuracy: accuracy,
      speedKmh: speedKmh,
    );
  }

  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;
    try {
      await _peripheral.stopAdvertising();
    } catch (_) {}
    _isAdvertising = false;
  }

  // ── Scanning (receive peers' locations) ─────────────────────────────────────

  /// Start BLE scanning for nearby BusIndia peers.
  /// Returns `true` if scanning started successfully.
  Future<bool> startScanning() async {
    try {
      final authorized = await _central.authorize();
      if (!authorized) return false;
      if (_central.state != BluetoothLowEnergyState.poweredOn) return false;

      if (_isScanning) await stopScanning();

      _discoverySubscription =
          _central.discovered.listen(_handleDiscovery);
      await _central.startDiscovery(serviceUUIDs: [_serviceUUID]);
      _isScanning = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopScanning() async {
    if (!_isScanning) return;
    try {
      await _central.stopDiscovery();
    } catch (_) {}
    await _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _isScanning = false;
  }

  // ── Location fallback ────────────────────────────────────────────────────────

  /// Returns the location of the closest fresh peer, or `null` if none.
  /// Use this when GPS is unavailable.
  BluetoothPeer? get bestFallbackPeer {
    _evictStalePeers();
    if (_peers.isEmpty) return null;
    return _peers.values.reduce(
      (a, b) => a.estimatedDistanceMeters <= b.estimatedDistanceMeters ? a : b,
    );
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  void _handleDiscovery(DiscoveredEventArgs event) {
    ManufacturerSpecificData? msd;
    for (final d in event.advertisement.manufacturerSpecificData) {
      if (d.id == _manufacturerId) {
        msd = d;
        break;
      }
    }
    if (msd == null) return;

    final peer = _decode(
      deviceId: event.peripheral.uuid.toString(),
      data: msd.data,
      rssi: event.rssi,
    );
    if (peer == null) return;

    _peers[peer.deviceId] = peer;
    _evictStalePeers();
    _peersController.add(List.unmodifiable(_peers.values.toList()));
  }

  /// Binary encoding: lat(4) + lng(4) + accuracy×10(2) + speed×10(2) + unixSecs(4) = 16 bytes.
  Uint8List _encode({
    required double lat,
    required double lng,
    required double accuracy,
    required double speedKmh,
  }) {
    final buf = ByteData(16);
    buf.setFloat32(0, lat.clamp(-90.0, 90.0).toDouble(), Endian.big);
    buf.setFloat32(4, lng.clamp(-180.0, 180.0).toDouble(), Endian.big);
    buf.setUint16(8, (accuracy * 10).round().clamp(0, 65535).toInt(), Endian.big);
    buf.setUint16(10, (speedKmh * 10).round().clamp(0, 65535).toInt(), Endian.big);
    buf.setUint32(
      12,
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).clamp(0, 0xFFFFFFFF).toInt(),
      Endian.big,
    );
    return buf.buffer.asUint8List();
  }

  BluetoothPeer? _decode({
    required String deviceId,
    required Uint8List data,
    required int rssi,
  }) {
    if (data.length < 16) return null;
    try {
      final buf = ByteData.sublistView(data, 0, 16);
      final lat = buf.getFloat32(0, Endian.big);
      final lng = buf.getFloat32(4, Endian.big);
      final accuracy = buf.getUint16(8, Endian.big) / 10.0;
      final speedKmh = buf.getUint16(10, Endian.big) / 10.0;
      final unixSecs = buf.getUint32(12, Endian.big);

      // Sanity check coordinates.
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;

      return BluetoothPeer(
        deviceId: deviceId,
        lat: lat,
        lng: lng,
        accuracy: accuracy,
        speedKmh: speedKmh,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(unixSecs * 1000),
        rssi: rssi,
      );
    } catch (_) {
      return null;
    }
  }

  void _evictStalePeers() {
    final cutoff = DateTime.now().subtract(_staleDuration);
    _peers.removeWhere((_, p) => p.timestamp.isBefore(cutoff));
  }

  Future<void> dispose() async {
    await stopAdvertising();
    await stopScanning();
    await _peersController.close();
  }
}
