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
    // مطمئن شو بلوتوث روشن است
    await FlutterBluePlus.turnOn();

    // تعریف سرویس و خصیصه‌ها
    final service = BluetoothService(
      serviceUuid: Guid(BleIds.serviceUuid),
      primary: true,
      characteristics: [
        BluetoothCharacteristic(
          uuid: Guid(BleIds.amountCharUuid),
          properties: CharProperties.write,      // خریدار می‌نویسد: [amount|nameLen|name]
          descriptors: const [],
        ),
        BluetoothCharacteristic(
          uuid: Guid(BleIds.ackCharUuid),
          properties: CharProperties.notify,     // فروشنده ACK می‌فرستد
          descriptors: const [],
        ),
      ],
    );

    // رجیستر سرویس روی GATT Server
    await FlutterBluePlus.addService(service);

    // گرفتن رفرنس خصیصه‌ها
    for (final c in service.characteristics) {
      if (c.uuid.str == BleIds.amountCharUuid) _amountChar = c;
      if (c.uuid.str == BleIds.ackCharUuid) _ackChar = c;
    }

    // شروع تبلیغ (discoverable)
    await FlutterBluePlus.startAdvertising(
      name: "SOMA_Seller",
      serviceUuids: [BleIds.serviceUuid],
    );

    // گوش دادن به داده‌های ورودی روی amountChar
    FlutterBluePlus.onCharacteristicReceived.listen((req) async {
      // فقط وقتی مربوط به خصیصه مبلغ است
      if (req.characteristic.uuid.str != BleIds.amountCharUuid) return;

      final bytes = req.value;
      if (bytes.length < 8) return;

      // payload: [amount(4 bytes LE)] [nameLen(4 bytes LE)] [buyerName (UTF8)]
      final bd0 = ByteData.sublistView(bytes, 0, 4);
      final bd1 = ByteData.sublistView(bytes, 4, 8);
      final amount = bd0.getUint32(0, Endian.little);
      final nameLen = bd1.getUint32(0, Endian.little);
      if (8 + nameLen > bytes.length) return;

      final buyerName = String.fromCharCodes(bytes.sublist(8, 8 + nameLen));

      // افزایش موجودی فروشنده
      final newBal = await _increaseBalance(amount);

      // کال‌بک به UI
      onPayment(amount, buyerName);

      // ارسال ACK (4 بایت: newBalance LE)
      if (_ackChar != null) {
        final ack = Uint8List(4)..buffer.asByteData().setUint32(0, newBal, Endian.little);
        await _ackChar!.setNotifyValue(true);
        await _ackChar!.write(ack, withoutResponse: false);
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
