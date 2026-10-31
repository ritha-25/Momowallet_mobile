import 'package:flutter/material.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  void _send() {
    final phone = _phoneCtrl.text.trim();
    final amount = int.tryParse(_amountCtrl.text.trim());

    if (phone.length != 10 || !(phone.startsWith('078') || phone.startsWith('079'))) {
      _err('Phone must be 10 digits and start with 078 or 079');
      return;
    }
    if (amount == null || amount < 100) {
      _err('Amount must be at least 100 RWF');
      return;
    }
    
    // We no longer check balance here, Firestore handles the list. 
    // (In a real app, you'd check the balance before allowing the send).
    
    Navigator.pop(context, {
      'description': 'Sent to $phone',
      'amount': amount,
    });
  }

  void _err(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Recipient phone',
                hintText: '078xxxxxxx',
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
            ElevatedButton(onPressed: _send, child: const Text('Send')),
          ],
        ),
      ),
    );
  }
}