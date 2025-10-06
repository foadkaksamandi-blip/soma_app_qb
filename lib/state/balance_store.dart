import 'package:shared_preferences/shared_preferences.dart';

/// مدیریت موجودی محلی برای Buyer و Seller
class BalanceStore {
  static const _buyerKey = 'buyer_balance';
  static const _sellerKey = 'seller_balance';

  /// دریافت موجودی خریدار
  static Future<int> getBuyerBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_buyerKey) ?? 100000; // مقدار پیش‌فرض 100,000 ریال
  }

  /// دریافت موجودی فروشنده
  static Future<int> getSellerBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sellerKey) ?? 0;
  }

  /// کاهش موجودی خریدار پس از پرداخت
  static Future<void> decreaseBuyerBalance(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_buyerKey) ?? 100000;
    prefs.setInt(_buyerKey, current - amount);
  }

  /// افزایش موجودی فروشنده پس از دریافت
  static Future<void> increaseSellerBalance(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_sellerKey) ?? 0;
    prefs.setInt(_sellerKey, current + amount);
  }
}
