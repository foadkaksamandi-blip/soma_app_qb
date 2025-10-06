import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Requests all needed runtime permissions for BLE on Android.
/// Returns `true` if everything is granted.
Future<bool> requestBlePermissions() async {
  if (!Platform.isAndroid) return true;

  final statuses = await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.locationWhenInUse, // required by many devices for BLE scan
  ].request();

  return statuses.every((s) => s.isGranted);
}

/// Checks (without prompting) whether required BLE permissions are granted.
Future<bool> hasBlePermissions() async {
  if (!Platform.isAndroid) return true;

  final checks = await Future.wait<bool>([
    Permission.bluetooth.isGranted,
    Permission.bluetoothScan.isGranted,
    Permission.bluetoothConnect.isGranted,
    Permission.bluetoothAdvertise.isGranted,
    Permission.locationWhenInUse.isGranted,
  ]);

  return checks.every((ok) => ok);
}
```0
