import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../common/ble_ids.dart';
import '../state/balance_store.dart';

class BleSeller {
  final void Function(int amount, String buyer) onPayment;
  BleSeller({required this.onPayment});

  BluetoothCharacteristic? _amountChar;
  BluetoothCharacteristic? _ackChar;

  bool get isAdvertising => FlutterBluePlus.isAdvertising;

  Future<void> start() async {
    // روشن بودن بلوتوث
    await FlutterBluePlus.turnOn();

    // تعریف سرویس و خصیصه‌ها
    final service = BluetoothService(
      serviceUuid: Guid(BleIds.serviceUuid),
      primary: true,
      characteristics: [
        // خریدار روی این characteristic مبلغ را می‌نویسد
        BluetoothCharacteristic(
          uuid: Guid(BleIds.amountCharUuid),
          properties: CharProperties.write,
          descriptors: [],
        ),
        // فروشنده از این characteristic نوتیفای/ACK می‌فرستد
        BluetoothCharacteristic(
          uuid: Guid(BleIds.ackCharUuid),
          properties: CharProperties.notify,
          descriptors: [],
        ),
      ],
    );

    // نگهداری رفرنس‌ها برای ACK
    for (final c in service.characteristics) {
      if (c.uuid.str == BleIds.amountCharUuid) _amountChar = c;
      if (c.uuid.str == BleIds.ackCharUuid) _ackChar = c;
    }

    // ثبت سرویس و شروع تبلیغ
    await FlutterBluePlus.addService(service);
    await FlutterBluePlus.startAdvertising(
      name: "SOMA_Seller",
      serviceUuids: [BleIds.serviceUuid],
    );

    // گوش‌دادن به نوشتن مبلغ از طرف خریدار
    FlutterBluePlus.onCharacteristicReceived.listen((req) async {
      // فقط درخواست‌هایی که روی amount characteristic آمده‌اند پردازش کن
      if (req.characteristic.uuid.str != BleIds.amountCharUuid) return;

      final bytes = req.value;
      if (bytes.length < 8) return;

      // قالب پیام: [amount(4 bytes LE)] [nameLen(4 bytes LE)] [buyerName(nameLen)]
      final bd1 = ByteData.sublistView(bytes, 0, 4);
      final bd2 = ByteData.sublistView(bytes, 4, 8);
      final amount = bd1.getUint32(0, Endian.little);
      final nameLen = bd2.getUint32(0, Endian.little);
      final buyerName = String.fromCharCodes(bytes.sublist(8, 8 + nameLen));

      // افزایش موجودی و گرفتن موجودی جدید
      final newBal = await _increaseBalance(amount);

      // کال‌بک برای UI
      onPayment(amount, buyerName);

      // ارسال ACK (چهار بایت اول = موجودی جدید به صورت LE)
      if (_ackChar != null) {
        final ack = Uint8List(4);
        ack.buffer.asByteData().setUint32(0, newBal, Endian.little);
        await _ackChar!.setNotifyValue(true);
        await _ackChar!.write(ack, withoutResponse: false);
      }

      // پاسخ به درخواست نوشتن (در صورت نیاز به پاسخ سطح GATT)
      try {
        await req.respondSuccess();
      } catch (_) {
        // برخی پلتفرم‌ها پاسخ صریح نیاز ندارند
      }
    });
  }

  Future<int> _increaseBalance(int amount) async {
    final old = await BalanceStore.getBalance();
    final nw = old + amount;
    await BalanceStore.setBalance(nw);
    return nw;
  }

  Future<void> stop() async {
    if (isAdvertising) {
      await FlutterBluePlus.stopAdvertising();
    }
  }
}
