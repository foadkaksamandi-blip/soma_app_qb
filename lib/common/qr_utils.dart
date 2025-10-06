import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrUtils {
  /// ساخت QR با داده مبلغ و شناسه فروشنده
  static Widget generatePaymentQr({
    required String sellerId,
    required int amount,
    double size = 200,
  }) {
    final qrData = 'SOMA|SELLER:$sellerId|AMOUNT:$amount';
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  /// تفسیر داده QR برای خریدار
  static Map<String, dynamic> parseQrData(String data) {
    try {
      final parts = data.split('|');
      final seller = parts.firstWhere((e) => e.startsWith('SELLER:')).split(':')[1];
      final amount = int.parse(parts.firstWhere((e) => e.startsWith('AMOUNT:')).split(':')[1]);
      return {'sellerId': seller, 'amount': amount};
    } catch (_) {
      return {'sellerId': '', 'amount': 0};
    }
  }
}
``` ✅
