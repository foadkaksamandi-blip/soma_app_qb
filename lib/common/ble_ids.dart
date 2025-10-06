/// UUID definitions for SOMA Offline BLE communication.
class BleIds {
  /// Primary GATT Service for SOMA transfers
  static const String serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

  /// Buyer → Seller: send amount + metadata
  static const String amountCharUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  /// Seller → Buyer: send acknowledgment (ACK)
  static const String ackCharUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  /// Seller → Buyer: optional status or transaction ID
  static const String statusCharUuid = "6e400004-b5a3-f393-e0a9-e50e24dcca9e";
}
