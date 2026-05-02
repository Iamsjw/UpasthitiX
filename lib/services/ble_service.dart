import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
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
  // Uses flutter_ble_peripheral to broadcast a BLE advertisement containing
  // the session ID encoded in the service data field.
  static bool _isAdvertising = false;

  static Future<bool> isPeripheralSupported() async {
    if (kIsWeb) return false;
    try {
      return await FlutterBlePeripheral().isSupported;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> startAdvertising(String sessionId) async {
    if (kIsWeb) return false;

    final isOn = await isBluetoothOn();
    if (!isOn) {
      debugPrint('[BLE] Cannot advertise: Bluetooth is off');
      return false;
    }

    try {
      final supported = await isPeripheralSupported();
      if (!supported) {
        debugPrint('[BLE] Peripheral mode not supported on this device');
        return false;
      }

      // Encode sessionId as UTF-8 bytes for service data
      final sessionBytes = utf8.encode(sessionId);

      final advertiseData = AdvertiseData(
        serviceUuid: _serviceUuid,
        localName: 'UpasthitiX',
        serviceData: sessionBytes,
      );

      await FlutterBlePeripheral().start(advertiseData: advertiseData);

      _isAdvertising = true;
      debugPrint('[BLE] Started advertising session: $sessionId');
      return true;
    } catch (e) {
      debugPrint('[BLE] Failed to start advertising: $e');
      return false;
    }
  }

  static Future<void> stopAdvertising() async {
    try {
      await FlutterBlePeripheral().stop();
    } catch (e) {
      debugPrint('[BLE] Error stopping advertising: $e');
    }
    _isAdvertising = false;
    debugPrint('[BLE] Stopped advertising');
  }

  static bool get isAdvertising => _isAdvertising;

  // ─── Student: BLE Scanning ────────────────────────────────────────────────
  // Scans for BLE advertisements that contain the target session ID in their
  // service data, manufacturer data, or device name.
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
          final matched = _isTargetSession(result, sessionId);
          if (matched) {
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

  /// Checks whether a BLE scan result matches the target session.
  /// Matches by:
  ///  1. Service data containing the session ID
  ///  2. Manufacturer data containing the session ID
  ///  3. Device name containing the session ID prefix (fallback)
  static bool _isTargetSession(ScanResult result, String sessionId) {
    try {
      final targetPrefix = sessionId.substring(0, min(8, sessionId.length));

      // Check service data (primary method with flutter_ble_peripheral)
      final svcData = result.advertisementData.serviceData;
      for (final entry in svcData.entries) {
        final key = entry.key.toString();
        if (key.toLowerCase().contains(_serviceUuid.toLowerCase()) ||
            key.toLowerCase().contains(targetPrefix.toLowerCase())) {
          final decoded = utf8.decode(entry.value, allowMalformed: true);
          if (decoded.contains(sessionId) || decoded.contains(targetPrefix)) {
            return true;
          }
        }
      }

      // Check manufacturer data (Map<int, List<int>>)
      final mfgData = result.advertisementData.manufacturerData;
      for (final entry in mfgData.entries) {
        final decoded = utf8.decode(entry.value, allowMalformed: true);
        if (decoded.contains(sessionId) || decoded.contains(targetPrefix)) {
          return true;
        }
      }

      // Fallback: match by device name (original approach)
      final name = result.device.platformName;
      final advName = result.advertisementData.advName;
      final targetName = 'UX_$targetPrefix';

      if (name.contains(targetName) ||
          advName.contains(targetName) ||
          name.contains('UpasthitiX') ||
          advName.contains('UpasthitiX')) {
        return true;
      }
    } catch (e) {
      debugPrint('[BLE] Error matching session: $e');
    }
    return false;
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
