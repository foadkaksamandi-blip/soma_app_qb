import 'package:shared_preferences/shared_preferences.dart';

class BalanceStore {
  static const String _key = 'balance';

  static Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 100000; // default balance in Rial
  }

  static Future<void> setBalance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value);
  }

  static Future<void> increase(int amount) async {
    final current = await getBalance();
    await setBalance(current + amount);
  }

  static Future<void> decrease(int amount) async {
    final current = await getBalance();
    await setBalance((current - amount).clamp(0, double.infinity).toInt());
  }
}
