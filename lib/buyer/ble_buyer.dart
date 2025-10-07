import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../state/balance_store.dart';

class BleBuyer {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _device;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  Future<void> connect(String deviceId) async {
    final devices = await flutterBlue.connectedDevices;
    _device = devices.firstWhere((d) => d.remoteId.str == deviceId,
        orElse: () => throw Exception("Device not found"));
    await _device!.connect(autoConnect: false);
    _connSub =
        _device!.connectionState.listen((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.disconnected) {
        _device = null;
      }
    });
  }

  Future<void> disconnect() async {
    await _connSub?.cancel();
    if (_device != null) {
      await _device!.disconnect();
      _device = null;
    }
  }

  Future<void> sendPayment(double amount) async {
    final oldBalance = await BalanceStore.getBuyerBalance();
    final newBalance = oldBalance - amount;
    await BalanceStore.setBuyerBalance(newBalance);
  }
}
