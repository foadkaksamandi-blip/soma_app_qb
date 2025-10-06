/// UUIDهای ثابت برای سرویس BLE و مشخصه‌های پرداخت
class BleIds {
  /// سرویس اصلی SOMA برای تراکنش‌ها
  static const String serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

  /// مشخصه ارسال مبلغ از خریدار به فروشنده
  static const String amountCharUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  /// مشخصه دریافت تأیید (ACK) از فروشنده
  static const String ackCharUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
}
