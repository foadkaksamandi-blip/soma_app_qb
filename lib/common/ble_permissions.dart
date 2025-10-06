import 'package:permission_handler/permission_handler.dart';

class BlePermissions {
  /// درخواست مجوزهای لازم برای استفاده از BLE و موقعیت
  static Future<bool> requestAll() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    return statuses.every((s) => s.isGranted);
  }

  /// بررسی اینکه آیا تمام مجوزهای مورد نیاز قبلاً داده شده‌اند یا نه
  static Future<bool> allGranted() async {
    return await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.bluetoothAdvertise.isGranted &&
        await Permission.locationWhenInUse.isGranted;
  }
}
