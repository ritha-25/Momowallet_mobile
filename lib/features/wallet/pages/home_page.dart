import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../data/model/transaction.dart';
import '../../../data/model/wallet.dart';
import '../../../data/repositories/walletrepo.dart';
import 'cashout_page.dart';
import 'send_page.dart';
import 'rate_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Wallet? wallet;
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await MockWalletRepository().load();
    if (!mounted) return;
    setState(() => wallet = loaded);
  }

  List<Transaction> get shown {
    final all = wallet!.transactions;
    if (filter == 'IN') return all.where((t) => t.isIn).toList();
    if (filter == 'OUT') return all.where((t) => !t.isIn).toList();
    return all;
  }

  Future<void> _openSend() async {
    final amount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => SendPage(balance: wallet!.balance)),
    );
    if (amount == null || !mounted) return;

    await wallet!.addOut(amount, 'Sent money');
    if (!mounted) return;
    setState(() {});
    _toast('Sent $amount RWF');
  }

  Future<void> _openCashout() async {
    final amount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => CashoutPage(balance: wallet!.balance)),
    );
    if (amount == null || !mounted) return;

    await wallet!.addOut(amount, 'Cash out');
    if (!mounted) return;
    setState(() {});
    _toast('Cashed out $amount RWF');
  }

  Future<void> _delete(Transaction t) async {
    final index = wallet!.transactions.indexOf(t);
    await wallet!.remove(t, index);
    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${t.description} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await wallet!.restore(t, index);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    if (wallet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('MoMo Wallet')),
      body: Column(
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
                const Text('Available balance',
                    style: TextStyle(color: AppColors.dark, fontSize: 14)),
                const SizedBox(height: 6),
                Text('${wallet!.balance} RWF',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark)),
              ],
            ),
          ),
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    children: [
      Expanded(
        child: _actionBtn(
            icon: Icons.send, label: 'Send', onTap: _openSend),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _actionBtn(
            icon: Icons.atm, label: 'Cash out', onTap: _openCashout),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _actionBtn(
          icon: Icons.currency_exchange,
          label: 'Rates',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RatesPage()),
          ),
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
                for (final f in ['All', 'IN', 'OUT'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: filter == f,
                      onSelected: (_) => setState(() => filter = f),
                    ),
                  ),
                const Spacer(),
                Text('${shown.length} txns',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? const Center(child: Text('No transactions yet'))
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, index) {
                      final t = shown[index];
                      final color = t.isIn ? AppColors.green : AppColors.red;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(
                            t.isIn ? Icons.arrow_downward : Icons.arrow_upward,
                            color: color,
                          ),
                        ),
                        title: Text(t.description),
                        subtitle: Text(t.isIn ? 'IN' : 'OUT',
                            style: TextStyle(color: color)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${t.isIn ? "+" : "-"}${t.amount}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: color),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.grey, size: 20),
                              onPressed: () => _delete(t),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
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
                offset: const Offset(0, 2)),
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