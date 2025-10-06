import 'package:permission_handler/permission_handler.dart';

/// مدیریت و درخواست مجوزهای BLE برای اپ‌های SOMA
class BlePermissions {
  static Future<bool> requestAll() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }
}
