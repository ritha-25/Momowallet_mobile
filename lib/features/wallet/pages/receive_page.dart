import 'package:flutter/material.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  void _receive() {
    final amount = int.tryParse(_amountCtrl.text.trim());
    final desc = _descCtrl.text.trim();

    if (amount == null || amount <= 0) {
      _err('Amount must be greater than 0');
      return;
    }
    if (desc.isEmpty) {
      _err('Description cannot be empty');
      return;
    }
    
    // Return a map with the amount and description back to the HomePage
    Navigator.pop(context, {
      'description': desc,
      'amount': amount,
    });
  }

  void _err(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Money')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'From (Description)',
                hintText: 'e.g. From Keza',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (RWF)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _receive,
              child: const Text('Receive'),
            ),
          ],
        ),
      ),
    );
  }
}