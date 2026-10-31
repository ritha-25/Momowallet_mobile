import 'package:cloud_firestore/cloud_firestore.dart'
show FieldValue, FirebaseException, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/model/transaction.dart';
import '../../../theme/app_theme.dart';
import 'cashout_page.dart';
import 'rate_page.dart';
import 'send_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _filter = 'All';

  Future<void> _openSend() async {
    final result = await Navigator.push<Map<String, Object>>(
      context,
      MaterialPageRoute(builder: (_) => const SendPage()),
    );
    if (result == null || !mounted) return;

    await _addTransaction(
      description: result['description']! as String,
      amount: result['amount']! as int,
      isIn: false,
    );
  }

  Future<void> _openCashout() async {
    final amount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const CashoutPage()),
    );
    if (amount == null || !mounted) return;

    await _addTransaction(description: 'Cash out', amount: amount, isIn: false);
  }

  Future<void> _addTransaction({
    required String description,
    required int amount,
    required bool isIn,
  }) async {
    try {
      await myTransactions().add({
        ...Transaction(
          description: description,
          amount: amount,
          isIn: isIn,
        ).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) _toast('$description recorded');
    } on FirebaseException catch (error) {
      if (mounted) _toast('Could not save transaction: ${error.message}');
    }
  }

  Future<void> _delete(Transaction transaction) async {
    try {
      await myTransactions().doc(transaction.id).delete();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${transaction.description} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _addTransaction(
              description: transaction.description,
              amount: transaction.amount,
              isIn: transaction.isIn,
            ),
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (mounted) _toast('Could not delete transaction: ${error.message}');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoMo Wallet'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Exchange rates',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const RatesPage()),
            ),
            icon: const Icon(Icons.currency_exchange),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myTransactions().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load transactions: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions =
              snapshot.data!.docs.map(Transaction.fromDoc).toList()..sort(
                (a, b) =>
                    (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                        .compareTo(
                          a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
                        ),
              );
          final shown = switch (_filter) {
            'IN' =>
              transactions.where((transaction) => transaction.isIn).toList(),
            'OUT' =>
              transactions.where((transaction) => !transaction.isIn).toList(),
            _ => transactions,
          };
          final balance = transactions.fold<int>(
            0,
            (total, transaction) => transaction.isIn
                ? total + transaction.amount
                : total - transaction.amount,
          );

          return Column(
            children: [
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
                    const Text(
                      'Available balance',
                      style: TextStyle(color: AppColors.dark, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$balance RWF',
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.send,
                        label: 'Send',
                        onTap: _openSend,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.atm,
                        label: 'Cash out',
                        onTap: _openCashout,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final filter in ['All', 'IN', 'OUT'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      '${shown.length} txns',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? const Center(child: Text('No transactions yet'))
                    : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final transaction = shown[index];
                          final color = transaction.isIn
                              ? AppColors.green
                              : AppColors.red;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Icon(
                                transaction.isIn
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: color,
                              ),
                            ),
                            title: Text(transaction.description),
                            subtitle: Text(
                              transaction.isIn ? 'IN' : 'OUT',
                              style: TextStyle(color: color),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${transaction.isIn ? "+" : "-"}${transaction.amount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete transaction',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () => _delete(transaction),
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.dark),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
