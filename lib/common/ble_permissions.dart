import 'package:permission_handler/permission_handler.dart';

class BlePermissions {
  /// درخواست تمام مجوزهای موردنیاز BLE
  static Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    // بررسی اینکه همه مجوزها داده شده باشند
    return statuses.every((status) => status.isGranted);
  }

  /// بررسی وضعیت فعلی مجوزها (بدون درخواست مجدد)
  static Future<bool> checkPermissions() async {
    return await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.bluetoothAdvertise.isGranted &&
        await Permission.locationWhenInUse.isGranted;
  }
}
