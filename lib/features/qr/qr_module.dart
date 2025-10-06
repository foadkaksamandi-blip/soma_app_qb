import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Payload ساده برای QR: نسخه، مبلغ، شناسه فروشنده، زمان
/// قالب داده: SOMA|v1|<amount>|<seller_id>|<timestamp_ms>
class QrPayload {
  final int amount;
  final String sellerId; // می‌تونه همون نام بلوتوثی یا شناسه داخلی باشه
  final int ts;

  QrPayload({
    required this.amount,
    required this.sellerId,
    required this.ts,
  });

  String toData() => 'SOMA|v1|$amount|$sellerId|$ts';

  static QrPayload? tryParse(String raw) {
    try {
      final parts = raw.trim();
      if (parts.isEmpty) return null;
      final segs = parts.split('|');
      if (segs.length < 5) return null;
      if (segs[0] != 'SOMA' || segs[1] != 'v1') return null;
      final amt = int.parse(segs[2]);
      final sid = segs[3];
      final t = int.parse(segs[4]);
      return QrPayload(amount: amt, sellerId: sid, ts: t);
    } catch (_) {
      return null;
    }
  }
}

/// ویجت تولید QR برای فروشنده.
/// شما مقدار را به آن می‌دهید تا QR بسازد. خریدار همان رشته را وارد/اسکن می‌کند.
class SellerQrCard extends StatelessWidget {
  final int amount;
  final String sellerId;
  final EdgeInsets padding;
  const SellerQrCard({
    super.key,
    required this.amount,
    this.sellerId = 'SOMA_Seller',
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final payload = QrPayload(
      amount: amount,
      sellerId: sellerId,
      ts: DateTime.now().millisecondsSinceEpoch,
    ).toData();

    return Card(
      margin: padding,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('QR پرداخت فروشنده', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: 220,
            ),
            const SizedBox(height: 12),
            SelectableText(
              payload,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'خریدار می‌تواند این رشته را وارد کند یا با اسکنر خود بخواند.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// دیالوگ ساده برای خریدار تا رشتهٔ QR را وارد/پیست کند.
/// پس از parse موفق، callback با QrPayload صدا زده می‌شود.
class BuyerEnterQrDialog extends StatefulWidget {
  final void Function(QrPayload payload) onParsed;
  const BuyerEnterQrDialog({super.key, required this.onParsed});

  @override
  State<BuyerEnterQrDialog> createState() => _BuyerEnterQrDialogState();
}

class _BuyerEnterQrDialogState extends State<BuyerEnterQrDialog> {
  final TextEditingController _ctrl = TextEditingController();
  String? _error;

  void _tryParse() {
    final payload = QrPayload.tryParse(_ctrl.text);
    if (payload == null) {
      setState(() => _error = 'فرمت QR نامعتبر است. (SOMA|v1|amount|seller|ts)');
      return;
    }
    Navigator.of(context).pop();
    widget.onParsed(payload);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ورود QR پرداخت'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'رشته QR را وارد/پیست کنید. (مثال: SOMA|v1|50000|SOMA_Seller|1712345678901)',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'SOMA|v1|<amount>|<seller_id>|<timestamp>',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('انصراف')),
        FilledButton(onPressed: _tryParse, child: const Text('تایید و ادامه')),
      ],
    );
  }
}

/// نمونه استفاده (راهنمای ادغام در صفحات اصلی):
///
/// --- در Seller (صفحه فروشنده):
/// 1) وقتی مبلغ خرید را تعیین کردید، این کارت را در UI نمایش دهید:
///
///   SellerQrCard(amount: _currentAmount, sellerId: 'SOMA_Seller')
///
/// 2) همزمان BLE Server را Start Advertising نگه دارید تا خریدار پس از دریافت مبلغ، با BLE پرداخت را بفرستد.
///
/// --- در Buyer (صفحه خریدار):
/// 1) روی دکمه «پرداخت با QR» دیالوگ زیر را باز کنید:
///
///   showDialog(
///     context: context,
///     builder: (_) => BuyerEnterQrDialog(
///       onParsed: (p) async {
///         // p.amount را بردار و همان گردش پرداخت BLE موجود را صدا بزن:
///         // مثال با BleBuyer موجود:
///         // await _buyer.scanAndPay(p.amount, _nameCtrl.text);
///         // سپس UI را آپدیت کن (کاهش موجودی، نمایش رسید، ...).
///       },
///     ),
///   );
///
/// نکته: برای اسکن با دوربین می‌توان بعداً پکیج اسکن را اضافه کرد.
/// این ماژول بدون وابستگی جدید build می‌شود و QR را تولید/مصرف می‌کند.
```0
