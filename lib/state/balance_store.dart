import 'package:shared_preferences/shared_preferences.dart';

/// Local persistent balance handler for SOMA Offline.
/// Keeps Buyer and Seller wallet values separately.
class BalanceStore {
  static const String _buyerKey = 'buyer_balance';
  static const String _sellerKey = 'seller_balance';

  /// Get current balance for Buyer or Seller.
  static Future<int> getBalance({required bool isBuyer}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(isBuyer ? _buyerKey : _sellerKey) ?? (isBuyer ? 100000 : 0);
  }

  /// Update balance value.
  static Future<void> setBalance(int value, {required bool isBuyer}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(isBuyer ? _buyerKey : _sellerKey, value);
  }

  /// Add amount to Seller balance.
  static Future<void> increase(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_sellerKey) ?? 0;
    await prefs.setInt(_sellerKey, current + amount);
  }

  /// Subtract amount from Buyer balance.
  static Future<void> decrease(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_buyerKey) ?? 100000;
    final newVal = current - amount;
    await prefs.setInt(_buyerKey, newVal < 0 ? 0 : newVal);
  }
}
