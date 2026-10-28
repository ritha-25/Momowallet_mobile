class Transaction {
  Transaction({
    required this.description,
    required this.amount,
    required this.isIn,
  });

  final String description;
  final int amount;
  final bool isIn;

  Map<String, dynamic> toJson() => {
    'description': description,
    'amount': amount,
    'isIn': isIn,
  };
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    description: json['description'] as String,
    amount: json['amount'] as int,
    isIn: json['isIn'] as bool,
  );
}
