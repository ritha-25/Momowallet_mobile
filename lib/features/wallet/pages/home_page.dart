import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../data/model/transaction.dart' hide Transaction; 
import '../../../data/model/transaction.dart' as txn_model;
import 'cashout_page.dart';
import 'send_page.dart';
import 'receive_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Future<void> addSampleData() async {
    final samples = [
      txn_model.Transaction(description: 'Opening balance', amount: 10000, isIn: true),
      txn_model.Transaction(description: 'Sent to 0788123456', amount: 2500, isIn: false),
      txn_model.Transaction(description: 'Received from Keza', amount: 4000, isIn: true),
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (final t in samples) {
      batch.set(myTransactions().doc(), {
        ...t.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _openSend(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SendPage()),
    );
    if (result != null) {
      await myTransactions().add({
        'description': result['description'],
        'amount': result['amount'],
        'isIn': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _openReceive(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const ReceivePage()),
    );
    if (result != null) {
      await myTransactions().add({
        'description': result['description'],
        'amount': result['amount'],
        'isIn': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _openCashout(BuildContext context) async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const CashoutPage()),
    );
    if (result != null) {
      await myTransactions().add({
        'description': 'Cash out',
        'amount': result,
        'isIn': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _delete(BuildContext context, txn_model.Transaction t) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: Text('Delete "${t.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (sure == true) {
      await myTransactions().doc(t.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoMo Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myTransactions().orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final txns = snapshot.data!.docs.map(txn_model.Transaction.fromDoc).toList();
          final balance = txns.fold<int>(0, (total, t) => t.isIn ? total + t.amount.toInt() : total - t.amount.toInt());

          return Column(
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.momoYellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available balance', style: TextStyle(color: AppColors.dark, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text('$balance RWF',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.dark)),
                  ],
                ),
              ),
              
              // Action Buttons (NOW 3 BUTTONS)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _actionBtn(icon: Icons.send, label: 'Send', onTap: () => _openSend(context)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(icon: Icons.download, label: 'Receive', onTap: () => _openReceive(context)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(icon: Icons.atm, label: 'Cash out', onTap: () => _openCashout(context)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Transaction List
              Expanded(
                child: txns.isEmpty
                    ? const Center(child: Text('No transactions yet.\nTap Receive to add money.', textAlign: TextAlign.center))
                    : ListView.builder(
                        itemCount: txns.length,
                        itemBuilder: (context, index) {
                          final t = txns[index];
                          final color = t.isIn ? AppColors.green : AppColors.red;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Icon(t.isIn ? Icons.arrow_downward : Icons.arrow_upward, color: color),
                            ),
                            title: Text(t.description),
                            subtitle: Text(t.isIn ? 'IN' : 'OUT', style: TextStyle(color: color)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${t.isIn ? "+" : "-"}${t.amount}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                  onPressed: () => _delete(context, t),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.dark),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}