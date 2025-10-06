import 'package:shared_preferences/shared_preferences.dart';

/// A helper class to store and manage user balances locally.
class BalanceStore {
  static const String _buyerKey = 'buyer_balance';
  static const String _sellerKey = 'seller_balance';
  static const String _txnKey = 'last_transaction';

  /// Gets the buyer's current balance.
  static Future<int> getBuyerBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_buyerKey) ?? 100000; // Default: 100,000 Rial
  }

  /// Gets the seller's current balance.
  static Future<int> getSellerBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sellerKey) ?? 0;
  }

  /// Updates buyer balance.
  static Future<void> setBuyerBalance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_buyerKey, value);
  }

  /// Updates seller balance.
  static Future<void> setSellerBalance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sellerKey, value);
  }

  /// Records last transaction details.
  static Future<void> recordTransaction(String details) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_txnKey, details);
  }

  /// Returns last recorded transaction.
  static Future<String?> getLastTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_txnKey);
  }
}
