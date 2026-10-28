import 'package:flutter/material.dart';

class CashoutPage extends StatefulWidget {
  const CashoutPage({super.key, required this.balance});
  final int balance;

  @override
  State<CashoutPage> createState() => _CashoutPageState();
}

class _CashoutPageState extends State<CashoutPage> {
  final _amountCtrl = TextEditingController();
  Map<int, int>? preview;

  static const notes = [5000, 2000, 1000, 500, 100];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _preview() {
    final amount = int.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 100) {
      _err('Amount must be at least 100 RWF');
      return;
    }
    if (amount % 100 != 0) {
      _err('Amount must be a multiple of 100');
      return;
    }
    if (amount > widget.balance) {
      _err('Insufficient balance');
      return;
    }
    var remaining = amount;
    final result = <int, int>{};
    for (final n in notes) {
      final c = remaining ~/ n;
      if (c > 0) result[n] = c;
      remaining = remaining % n;
    }
    setState(() => preview = result);
  }

  void _confirm() {
    final amount = int.parse(_amountCtrl.text.trim());
    Navigator.pop(context, amount);
  }

  void _err(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Out')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Balance: ${widget.balance} RWF',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (multiple of 100)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _preview, child: const Text('Preview notes')),
            const SizedBox(height: 16),
            if (preview != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You will receive:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...preview!.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('${e.key} × ${e.value}'),
                        )),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _confirm,
                        child: const Text('Confirm cash out')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}