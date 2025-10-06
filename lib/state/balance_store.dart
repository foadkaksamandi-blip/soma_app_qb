import 'package:shared_preferences/shared_preferences.dart';

/// ذخیره‌سازی ساده روی دستگاه (SharedPreferences)
/// - موجودی خریدار و فروشنده جداست (به ریال، int)
/// - آخرین تراکنش هر کدام جدا ذخیره می‌شود (رشته توضیحی)

class BalanceStore {
  static SharedPreferences? _prefs;

  // کلیدها
  static const _buyerKey = 'buyer_balance';
  static const _sellerKey = 'seller_balance';
  static const _buyerLastTxKey = 'buyer_last_tx';
  static const _sellerLastTxKey = 'seller_last_tx';

  /// حتماً قبل از استفاده، یکبار init فراخوانی شود (در main هر اپ)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // مقدار اولیه اگر خالی بود
    _prefs!.getInt(_buyerKey) ?? _prefs!.setInt(_buyerKey, 1_000_000); // پیشفرض خریدار: 1,000,000 ریال
    _prefs!.getInt(_sellerKey) ?? _prefs!.setInt(_sellerKey, 0);        // پیشفرض فروشنده: 0 ریال
  }

  // ------------------- Buyer -------------------

  static int getBuyerBalance() {
    return _prefs?.getInt(_buyerKey) ?? 0;
  }

  static Future<void> setBuyerBalance(int value) async {
    await _prefs?.setInt(_buyerKey, value);
  }

  static Future<void> incBuyer(int amount) async {
    final cur = getBuyerBalance();
    await setBuyerBalance(cur + amount);
  }

  static Future<void> decBuyer(int amount) async {
    final cur = getBuyerBalance();
    final next = cur - amount;
    await setBuyerBalance(next < 0 ? 0 : next);
  }

  static Future<void> setBuyerLastTx(String desc) async {
    await _prefs?.setString(_buyerLastTxKey, desc);
  }

  static String getBuyerLastTx() {
    return _prefs?.getString(_buyerLastTxKey) ?? '-';
  }

  // ------------------- Seller -------------------

  static int getSellerBalance() {
    return _prefs?.getInt(_sellerKey) ?? 0;
  }

  static Future<void> setSellerBalance(int value) async {
    await _prefs?.setInt(_sellerKey, value);
  }

  static Future<void> incSeller(int amount) async {
    final cur = getSellerBalance();
    await setSellerBalance(cur + amount);
  }

  static Future<void> decSeller(int amount) async {
    final cur = getSellerBalance();
    final next = cur - amount;
    await setSellerBalance(next < 0 ? 0 : next);
  }

  static Future<void> setSellerLastTx(String desc) async {
    await _prefs?.setString(_sellerLastTxKey, desc);
  }

  static String getSellerLastTx() {
    return _prefs?.getString(_sellerLastTxKey) ?? '-';
  }
}
