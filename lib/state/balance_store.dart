import 'package:shared_preferences/shared_preferences.dart';

/// مدیریت موجودی کاربر (خریدار یا فروشنده)
class BalanceStore {
  final String key;
  BalanceStore(this.key);

  /// دریافت موجودی فعلی
  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  /// تنظیم موجودی جدید
  Future<void> setBalance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// افزایش موجودی
  Future<void> increase(int amount) async {
    final current = await getBalance();
    await setBalance(current + amount);
  }

  /// کاهش موجودی
  Future<void> decrease(int amount) async {
    final current = await getBalance();
    final newValue = (current - amount).clamp(0, double.infinity).toInt();
    await setBalance(newValue);
  }
}
