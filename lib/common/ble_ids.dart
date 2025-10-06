import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// ثابت‌های BLE برای سرویس پرداخت SOMA (یکسان در هر دو اپ)
class BleIds {
  /// سرویس اختصاصی SOMA
  static final Guid service = Guid('a49b2b52-2579-4d43-911a-55b27a3c3937');

  /// خصوصیت ارسال مبلغ (Buyer → Seller) - Write
  static final Guid amountChar = Guid('c8524675-0193-4713-a436-1e358b683377');

  /// خصوصیت تأیید تراکنش (Seller → Buyer) - Notify
  static final Guid ackChar = Guid('d948e983-509f-402a-a38b-18ae4e7a85f4');

  /// پیشوند نام دستگاه فروشنده هنگام تبلیغ
  static const String sellerNamePrefix = 'SOMA_Seller';
}
```0
