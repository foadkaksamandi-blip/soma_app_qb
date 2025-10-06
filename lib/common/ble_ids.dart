/// UUIDهای سرویس و ویژگی‌های BLE برای دمو SOMA
/// در صورت نیاز می‌تونی UUIDها رو با مقادیر جدید جایگزین کنی
/// (اما این‌ها بین Buyer/Seller باید یکسان بمانند).
class BleIds {
  /// سرویس اصلی پرداخت
  static const String serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

  /// ویژگی Write برای ارسال مبلغ از خریدار به فروشنده
  static const String amountCharUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  /// ویژگی Notify/Indicate برای ارسال ACK از فروشنده به خریدار
  static const String ackCharUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
}
