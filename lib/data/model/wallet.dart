import 'transaction.dart';

class Wallet {
  Wallet({required this.balance, required this.transactions});

  int balance;
  List<Transaction> transactions;

  void addIn(int amount, String description) {
    balance += amount;
    transactions.insert(
      0,
      Transaction(description: description, amount: amount, isIn: true),
    );
  }

  void addOut(int amount, String description) {
    balance -= amount;
    transactions.insert(
      0,
      Transaction(description: description, amount: amount, isIn: false),
    );
  }

  void remove(Transaction t, int index) {
    balance += t.isIn ? -t.amount : t.amount;
    transactions.removeAt(index);
  }

  void restore(Transaction t, int index) {
    balance += t.isIn ? t.amount : -t.amount;
    transactions.insert(index, t);
  }
}