enum TransactionType {
  credit,
  debit,
}

class TransactionItem {
  final String hindiName;
  final String englishName;
  final double amount;
  final TransactionType type;
  final String date;
  final String category;

  TransactionItem({
    required this.hindiName,
    required this.englishName,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });
}
