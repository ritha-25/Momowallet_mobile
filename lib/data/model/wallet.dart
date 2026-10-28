import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction.dart';

class Wallet {
  Wallet({required this.balance, required this.transactions});

  int balance;
  List<Transaction> transactions;

  static const balanceKey = 'wallet_balance';
  static const transKey = 'wallet_transactions';

  static Future<Wallet> load() async {
    final preference = await SharedPreferences.getInstance();
    final savedBalance = preference.getInt(balanceKey);
    final savedTrans = preference.getString(transKey);

    if (savedBalance == null || savedTrans == null) {
      return Wallet(
        balance: 10000,
        transactions: [
          Transaction(description: 'Received from kally', amount: 5000, isIn: true),
          Transaction(description: 'sent to 0788123456', amount: 2000, isIn: false),
          Transaction(description: 'cashout', amount: 1000, isIn: false),
        ],
      );
    }

    final list = (jsonDecode(savedTrans) as List)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();

    return Wallet(balance: savedBalance, transactions: list);
  }

  Future<void> save() async {
    final preference = await SharedPreferences.getInstance();
    await preference.setInt(balanceKey, balance);
    await preference.setString(
      transKey,
      jsonEncode(transactions.map((t) => t.tojson()).toList()),
    );
  }

  Future<void> addIn(int amount, String description) async {
    balance += amount;
    transactions.insert(
      0,
      Transaction(description: description, amount: amount, isIn: true),
    );
    await save();
  }

  Future<void> addOut(int amount, String description) async {
    balance -= amount;
    transactions.insert(
      0,
      Transaction(description: description, amount: amount, isIn: false),
    );
    await save();
  }

  Future<void> remove(Transaction t, int index) async {
    balance += t.isIn ? -t.amount : t.amount;
    transactions.removeAt(index);
    await save();
  }

  Future<void> restore(Transaction t, int index) async {
    balance += t.isIn ? t.amount : -t.amount;
    transactions.insert(index, t);
    await save();
  }
}