enum TransactionType {
  credit,
  debit,
}

class TransactionItem {
  final String? id; // Optional ID from backend
  final String hindiName;
  final String englishName;
  final double? amount;
  final TransactionType type;
  final String date;
  final String category;
  final String? partyId; // Link to user
  final String? description;

  TransactionItem({
    this.id,
    required this.hindiName,
    required this.englishName,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.partyId,
    this.description,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      hindiName: json['party_name'] ?? '', // Backend uses party_name
      englishName: json['party_name'] ?? '', 
      amount: json['amount'].toDouble(),
      type: json['type'] == 'credit' ? TransactionType.credit : TransactionType.debit,
      date: _formatDate(json['date']), // Need handle ISO date
      category: json['category'],
      partyId: json['party_id'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'party_name': englishName, // Use english name as primary party name
      'amount': amount,
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'category': category,
      'date': _parseDateToIso(date),
      'party_id': partyId,
      'description': description,
    };
  }

  static String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.year}'; 
      // Returns dd-mm-yyyy for UI
    } catch (e) {
      return isoDate;
    }
  }

  static String _parseDateToIso(String uiDate) {
    try {
      // Input dd-mm-yyyy or similar
      // Check if already ISO
      if (uiDate.contains('T')) return uiDate;
      // Handle "15 Jan 2024" or "15-01-2024"
      // Simple fallback for now, assuming UI passes something parsable or we need a proper parser
      // If UI is 'dd-mm-yyyy':
      final parts = uiDate.split('-');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])).toIso8601String();
      }
      return DateTime.now().toIso8601String(); // Fallback
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }
}
