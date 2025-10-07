import 'package:shared_preferences/shared_preferences.dart';

class BalanceStore {
  static const _buyerKey = 'buyer_balance';
  static const _sellerKey = 'seller_balance';

  static Future<double> getBuyerBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_buyerKey) ?? 1000000.0;
  }

  static Future<void> setBuyerBalance(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_buyerKey, value);
  }

  static Future<double> getSellerBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_sellerKey) ?? 0.0;
  }

  static Future<void> setSellerBalance(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sellerKey, value);
  }
}
