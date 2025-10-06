import 'package:permission_handler/permission_handler.dart';

/// مدیریت و درخواست مجوزهای BLE و موقعیت مکانی
class BlePermissions {
  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }
}
