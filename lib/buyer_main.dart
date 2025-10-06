import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common/ble_permissions.dart';
import 'state/balance_store.dart';
import 'buyer/ble_buyer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BuyerApp());
}

class BuyerApp extends StatelessWidget {
  const BuyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOMA Buyer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const BuyerPage(),
    );
  }
}

class BuyerPage extends StatefulWidget {
  const BuyerPage({super.key});

  @override
  State<BuyerPage> createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  int _balance = 0;
  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: "Buyer");
  bool _working = false;
  String _status = "";
  late final BleBuyer _buyer;

  @override
  void initState() {
    super.initState();
    _buyer = BleBuyer()
      ..onReceipt = (paid, newBal) {
        if (!mounted) return;
        setState(() {
          _balance = newBal;
          _status = "رسید دریافت شد: $paid ریال";
          _working = false;
        });
      };
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final b = await BalanceStore.getBalance();
    if (mounted) setState(() => _balance = b);
  }

  Future<void> _pay() async {
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      setState(() => _status = "مبلغ نامعتبر است");
      return;
    }

    setState(() {
      _working = true;
      _status = "در حال اسکن فروشنده…";
    });

    final ok = await requestBlePermissions();
    if (!ok) {
      if (!mounted) return;
      setState(() {
        _status = "اجازه‌های لازم داده نشد";
        _working = false;
      });
      return;
    }

    try {
      await _buyer.scanAndPay(amount, _nameCtrl.text.trim().isEmpty ? "Buyer" : _nameCtrl.text.trim());
      // در صورت موفقیت، onReceipt وضعیت را به‌روزرسانی می‌کند
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = "خطا: $e";
        _working = false;
      });
    }
  }

  @override
  void dispose() {
    _buyer.dispose();
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOMA Buyer")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("موجودی (ریال)", style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(_balance.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "مبلغ پرداخت (ریال)"),
              enabled: !_working,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "نام شما (برای رسید)"),
              enabled: !_working,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _working ? null : _pay,
              icon: const Icon(Icons.bluetooth_searching),
              label: Text(_working ? "در حال پرداخت…" : "پرداخت از طریق BLE"),
            ),
            const SizedBox(height: 12),
            Text(_status, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
```0
