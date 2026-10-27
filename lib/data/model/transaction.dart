class Transaction {
  Transaction({
    required this.description,
    required this.amount,
    required this.isIn,
  });

  final String description;
  final int amount;
  final bool isIn;
}