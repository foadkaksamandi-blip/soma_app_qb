/// UUIDهای سرویس و ویژگی‌های BLE برای SOMA Offline
class BleIds {
  /// شناسه سرویس اصلی
  static const String serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

  /// ویژگی ارسال مبلغ (از خریدار به فروشنده)
  static const String amountCharUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  /// ویژگی ارسال تأییدیه (از فروشنده به خریدار)
  static const String ackCharUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
}
