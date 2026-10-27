import '../model/transaction.dart';
import '../model/wallet.dart';

class MockWalletRepository {
  Wallet load() {
    return Wallet(
      balance: 10000,
      transactions: [
        Transaction(description: 'Received from Keza', amount: 5000, isIn: true),
        Transaction(description: 'Sent to 0788123456', amount: 2000, isIn: false),
        Transaction(description: 'Cash out', amount: 1000, isIn: false),
      ],
    );
  }
}