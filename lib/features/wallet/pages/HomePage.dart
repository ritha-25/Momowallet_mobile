import 'package:flutter/material.dart';
import '../../../theme/appTheme.dart';
import '../../../data/model/transaction.dart';
import '../../../data/repositories/walletrepo.dart';
import 'sendPage.dart';
import 'HomePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final wallet = MockWalletRepository().load();
  String filter = 'All';

  List<Transaction> get shown {
    if (filter == 'IN') return wallet.transactions.where((t) => t.isIn).toList();
    if (filter == 'OUT') return wallet.transactions.where((t) => !t.isIn).toList();
    return wallet.transactions;
  }

  Future<void> _openSend() async {
    final amount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => SendPage(balance: wallet.balance)),
    );
    if (amount != null && mounted) {
      setState(() => wallet.addOut(amount, 'Sent money'));
      _toast('Sent $amount RWF');
    }
  }

  Future<void> _openCashout() async {
    final amount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => CashoutPage(balance: wallet.balance)),
    );
    if (amount != null && mounted) {
      setState(() => wallet.addOut(amount, 'Cash out'));
      _toast('Cashed out $amount RWF');
    }
  }

  void _delete(Transaction t) {
    final index = wallet.transactions.indexOf(t);
    setState(() => wallet.remove(t, index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${t.description} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => wallet.restore(t, index)),
        ),
      ),
    );
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
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
                Text('${wallet.balance} RWF',
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
                const SizedBox(width: 12),
                Expanded(
                  child: _actionBtn(
                      icon: Icons.atm, label: 'Cash out', onTap: _openCashout),
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
                          backgroundColor: color.withOpacity(0.15),
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
                color: Colors.black.withOpacity(0.05),
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