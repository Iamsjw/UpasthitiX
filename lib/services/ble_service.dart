import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleAdvertisementData {
  final String sessionId;
  final int rssi;
  final String deviceId;

  const BleAdvertisementData({
    required this.sessionId,
    required this.rssi,
    required this.deviceId,
  });
}

class BleService {
  static const String _serviceUuid = '12345678-1234-1234-1234-123456789abc';
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static Timer? _scanTimer;
  static final List<int> _rssiSamples = [];

  // ─── Permissions ──────────────────────────────────────────────────────────
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      // Permission.bluetooth is deprecated on Android 12+ (API 31+).
      // Only request modern BLE permissions + location for scanning.
      final permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ];

      final results = await permissions.request();

      final allGranted = results.values.every((s) => s == PermissionStatus.granted);
      debugPrint('[BLE] Permissions: $results -> granted=$allGranted');
      return allGranted;
    } catch (e) {
      debugPrint('[BLE] Permission request failed: $e');
      return false;
    }
  }

  /// Check if all required BLE permissions are granted (without requesting).
  static Future<bool> hasPermissions() async {
    if (kIsWeb) return false;
    try {
      final results = await Future.wait([
        Permission.bluetoothScan.status,
        Permission.bluetoothConnect.status,
        Permission.bluetoothAdvertise.status,
        Permission.locationWhenInUse.status,
      ]);
      return results.every((s) => s.isGranted);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isBluetoothOn() async {
    if (kIsWeb) return false;
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  // ─── Teacher: BLE Advertising ─────────────────────────────────────────────
  // NOTE: flutter_blue_plus does not support advertising on all devices.
  // We simulate advertising by encoding session_id in device name via scan.
  // For production, use flutter_ble_peripheral or native channels.
  static bool _isAdvertising = false;
  static String? _advertisingSessionId;

  static Future<bool> startAdvertising(String sessionId) async {
    if (kIsWeb) return false;
    final isOn = await isBluetoothOn();
    if (!isOn) {
      debugPrint('[BLE] Cannot advertise: Bluetooth is off');
      return false;
    }
    _isAdvertising = true;
    _advertisingSessionId = sessionId;
    // TODO: Replace with flutter_ble_peripheral for production advertising
    // Simulated: In production, use platform channel to start BLE advertising
    debugPrint('[BLE] Started advertising session: $sessionId');
    return true;
  }

  static Future<void> stopAdvertising() async {
    _isAdvertising = false;
    _advertisingSessionId = null;
    debugPrint('[BLE] Stopped advertising');
  }

  static bool get isAdvertising => _isAdvertising;

  // ─── Student: BLE Scanning ────────────────────────────────────────────────
  static Future<BleAdvertisementData?> scanForSession({
    required String sessionId,
    required int timeoutSeconds,
    required int rssiThreshold,
    void Function(int rssi)? onRssiUpdate,
  }) async {
    if (kIsWeb) return null;

    final isOn = await isBluetoothOn();
    if (!isOn) return null;

    _rssiSamples.clear();
    final completer = Completer<BleAdvertisementData?>();

    try {
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: timeoutSeconds),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          // Match by advertised name containing session_id prefix
          final name = result.device.platformName;
          final advName = result.advertisementData.advName;
          final targetName =
              'UX_${sessionId.substring(0, min(8, sessionId.length))}';

          if (name.contains(targetName) ||
              advName.contains(targetName) ||
              name.contains('UpasthitiX')) {
            final rssi = result.rssi;
            _rssiSamples.add(rssi);
            onRssiUpdate?.call(rssi);

            // Need 3 samples for stability
            if (_rssiSamples.length >= 3) {
              final avgRssi =
                  _rssiSamples.reduce((a, b) => a + b) ~/ _rssiSamples.length;
              if (!completer.isCompleted) {
                completer.complete(
                  BleAdvertisementData(
                    sessionId: sessionId,
                    rssi: avgRssi,
                    deviceId: result.device.remoteId.str,
                  ),
                );
              }
            }
          }
        }
      });

      _scanTimer = Timer(Duration(seconds: timeoutSeconds), () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      final result = await completer.future;
      await _stopScan();
      return result;
    } catch (e) {
      debugPrint('[BLE] Scan error: $e');
      await _stopScan();
      return null;
    }
  }

  static Future<void> _stopScan() async {
    try {
      _scanTimer?.cancel();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  static Future<void> dispose() async {
    await _stopScan();
    await stopAdvertising();
  }

  // ─── RSSI signal quality ──────────────────────────────────────────────────
  static String rssiQualityLabel(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    if (rssi >= -80) return 'Weak';
    return 'Very Weak';
  }

  static double rssiQualityPercent(int rssi) {
    // Map -100 to 0% and -30 to 100%
    return ((rssi + 100) / 70).clamp(0.0, 1.0);
  }
}
