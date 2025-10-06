import 'package:permission_handler/permission_handler.dart';

/// Handles runtime permission requests for BLE & Location.
class BlePermissions {
  /// Requests all necessary permissions for Bluetooth operations.
  static Future<bool> requestAll() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  /// Checks if all required permissions are already granted.
  static Future<bool> checkAll() async {
    final statuses = await Future.wait([
      Permission.bluetooth.status,
      Permission.bluetoothScan.status,
      Permission.bluetoothConnect.status,
      Permission.bluetoothAdvertise.status,
      Permission.locationWhenInUse.status,
    ]);
    return statuses.every((s) => s.isGranted);
  }
}
