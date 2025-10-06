import 'package:shared_preferences/shared_preferences.dart';

/// ذخیره‌سازی و مدیریت موجودی کاربر (خریدار یا فروشنده)
class BalanceStore {
  static const String _key = 'balance';

  /// دریافت موجودی فعلی
  static Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 100000; // مقدار پیش‌فرض: ۱۰۰٬۰۰۰ ریال
  }

  /// تنظیم موجودی جدید
  static Future<void> setBalance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value);
  }

  /// افزایش موجودی
  static Future<void> increase(int amount) async {
    final current = await getBalance();
    await setBalance(current + amount);
  }

  /// کاهش موجودی
  static Future<void> decrease(int amount) async {
    final current = await getBalance();
    await setBalance((current - amount).clamp(0, double.infinity).toInt());
  }
}
