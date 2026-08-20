class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime? timestamp;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  // =========================================================
  // FROM FIRESTORE
  // =========================================================

  factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return TransactionModel(
      id: id,
      type: map['type'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as dynamic).toDate()
          : null,
    );
  }
}