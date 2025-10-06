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
    await FlutterBluePlus.turnOn();

    final service = BluetoothService(
      serviceUuid: Guid(BleIds.serviceUuid),
      primary: true,
      characteristics: [
        BluetoothCharacteristic(
          uuid: Guid(BleIds.amountCharUuid),
          properties: CharProperties.write,
          descriptors: [],
        ),
        BluetoothCharacteristic(
          uuid: Guid(BleIds.ackCharUuid),
          properties: CharProperties.notify,
          descriptors: [],
        ),
      ],
    );

    await FlutterBluePlus.addService(service);
    await FlutterBluePlus.startAdvertising(
      name: "SOMA_Seller",
      serviceUuids: [BleIds.serviceUuid],
    );

    FlutterBluePlus.onCharacteristicReceived.listen((req) async {
      if (req.characteristic.uuid.str == BleIds.amountCharUuid) {
        final bytes = req.value;
        if (bytes.length < 8) return;
        final amount = ByteData.sublistView(bytes, 0, 4).getUint32(0, Endian.little);
        final buyerLen = ByteData.sublistView(bytes, 4, 8).getUint32(0, Endian.little);
        final buyer = String.fromCharCodes(bytes, 8, 8 + buyerLen);

        onPayment(amount, buyer);
        final newBal = await _increaseBalance(amount);

        final ackBytes = Uint8List(5)..buffer.asByteData().setUint32(0, newBal, Endian.little);
        if (_ackChar != null) {
          await _ackChar!.setNotifyValue(true);
          await _ackChar!.write(ackBytes, withoutResponse: false);
        }
      }
    });
  }

  Future<int> _increaseBalance(int amount) async {
    final old = await BalanceStore.getBalance();
    final newBal = old + amount;
    await BalanceStore.setBalance(newBal);
    return newBal;
  }

  Future<void> stop() async {
    if (isAdvertising) await FlutterBluePlus.stopAdvertising();
  }
}
