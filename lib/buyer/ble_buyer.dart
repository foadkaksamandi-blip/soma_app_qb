import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../common/ble_ids.dart';
import '../state/balance_store.dart';

typedef OnReceipt = void Function(int paid, int newBalance);

class BleBuyer {
  OnReceipt? onReceipt;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _amountChar;
  BluetoothCharacteristic? _ackChar;
  StreamSubscription? _scanSub;
  StreamSubscription? _connSub;

  /// شروع اسکن و پرداخت
  Future<void> scanAndPay(int amount, String buyerName) async {
    await FlutterBluePlus.turnOn();
    final completer = Completer<void>();

    _scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        if (r.device.platformName.contains("SOMA_Seller")) {
          await _scanSub?.cancel();
          _device = r.device;
          await _connect(amount, buyerName, completer);
          break;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    await completer.future;
  }

  Future<void> _connect(int amount, String buyerName, Completer<void> done) async {
    await _device!.connect(timeout: const Duration(seconds: 10));

    _connSub = FlutterBluePlus.onConnectionStateChanged.listen((s) async {
      if (s.device != _device) return;
      if (s.connectionState == BluetoothConnectionState.connected) {
        final services = await _device!.discoverServices();
        for (final s in services) {
          if (s.uuid.str == BleIds.serviceUuid) {
            for (final c in s.characteristics) {
              if (c.uuid.str == BleIds.amountCharUuid) _amountChar = c;
              if (c.uuid.str == BleIds.ackCharUuid) _ackChar = c;
            }
          }
        }
        if (_amountChar != null && _ackChar != null) {
          await _pay(amount, buyerName, done);
        }
      }
    });
  }

  Future<void> _pay(int amount, String buyerName, Completer<void> done) async {
    final old = await BalanceStore.getBalance();
    if (old < amount) {
      done.completeError("Insufficient balance");
      return;
    }
    await BalanceStore.setBalance(old - amount);

    // payload: amount + name length + name
    final nameBytes = Uint8List.fromList(buyerName.codeUnits);
    final payload = Uint8List(8 + nameBytes.length)
      ..buffer.asByteData().setUint32(0, amount, Endian.little)
      ..buffer.asByteData().setUint32(4, nameBytes.length, Endian.little)
      ..setAll(8, nameBytes);

    await _amountChar!.write(payload, withoutResponse: false);

    // منتظر ACK
    final sub = _ackChar!.onValueReceived.listen((val) {
      if (val.length >= 4) {
        final newBal = ByteData.sublistView(val, 0, 4).getUint32(0, Endian.little);
        onReceipt?.call(amount, newBal);
        done.complete();
      }
    });

    await done.future.timeout(const Duration(seconds: 10));
    sub.cancel();
    await _device?.disconnect();
  }

  Future<void> dispose() async {
    await _scanSub?.cancel();
    await _connSub?.cancel();
    await _device?.disconnect();
  }
}
