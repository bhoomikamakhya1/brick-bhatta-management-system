class BrickEntry {
  final String id;
  String brickType;
  double quantity;
  double price;

  BrickEntry({
    String? id,
    required this.brickType,
    required this.quantity,
    required this.price,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class FreightDetails {
  final String type; // 'self' or 'sending'
  String? vehicleNumber;
  String? vehicleName;
  String? driverName;
  String? driverPhone;
  double ratePer1000; // Freight rate per 1000 bricks

  FreightDetails({
    required this.type,
    this.vehicleNumber,
    this.vehicleName,
    this.driverName,
    this.driverPhone,
    this.ratePer1000 = 0.0,
  });
}

class SaleEntry {
  final String id;
  final String customerName;
  final String customerNameHindi;
  final String? customerAddress;
  final String? customerPhone;
  final DateTime date;
  final DateTime time;
  final List<BrickEntry> brickEntries;
  final double advancePayment;
  final FreightDetails? freightDetails;
  final double totalAmount;
  final double finalAmount; // Total minus advance
  final String? remarks;
  final String? otp;
  final String createdBy; // User ID who created this

  SaleEntry({
    String? id,
    required this.customerName,
    required this.customerNameHindi,
    this.customerAddress,
    this.customerPhone,
    required this.date,
    required this.time,
    required this.brickEntries,
    this.advancePayment = 0.0,
    this.freightDetails,
    required this.totalAmount,
    required this.finalAmount,
    this.remarks,
    this.otp,
    required this.createdBy,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    // Convert to snake_case for backend API compatibility
    return {
      'id': id,
      'customer_name': customerName,
      'customer_name_hindi': customerNameHindi,
      'customer_address': customerAddress,
      'customer_phone': customerPhone,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
      'brick_entries': brickEntries.map((e) => {
        'id': e.id,
        'brick_type': e.brickType,
        'quantity': e.quantity,
        'price': e.price,
      }).toList(),
      'advance_payment': advancePayment,
      'freight_details': freightDetails != null ? {
        'type': freightDetails!.type,
        'vehicle_number': freightDetails!.vehicleNumber,
        'vehicle_name': freightDetails!.vehicleName,
        'driver_name': freightDetails!.driverName,
        'driver_phone': freightDetails!.driverPhone,
        'rate_per_1000': freightDetails!.ratePer1000,
      } : null,
      'total_amount': totalAmount,
      'final_amount': finalAmount,
      'remarks': remarks,
      'otp': otp,
      'created_by': createdBy,
    };
  }

  factory SaleEntry.fromJson(Map<String, dynamic> json) {
    // Handle both snake_case (from backend) and camelCase (from local storage)
    final brickEntriesJson = json['brick_entries'] ?? json['brickEntries'] ?? [];
    final freightDetailsJson = json['freight_details'] ?? json['freightDetails'];
    
    return SaleEntry(
      id: json['id'],
      customerName: json['customer_name'] ?? json['customerName'] ?? '',
      customerNameHindi: json['customer_name_hindi'] ?? json['customerNameHindi'] ?? '',
      customerAddress: json['customer_address'] ?? json['customerAddress'],
      customerPhone: json['customer_phone'] ?? json['customerPhone'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      brickEntries: (brickEntriesJson as List)
          .map((e) => BrickEntry(
                id: e['id'],
                brickType: e['brick_type'] ?? e['brickType'] ?? '',
                quantity: (e['quantity'] as num).toDouble(),
                price: (e['price'] as num).toDouble(),
              ))
          .toList(),
      advancePayment: ((json['advance_payment'] ?? json['advancePayment']) as num?)?.toDouble() ?? 0.0,
      freightDetails: freightDetailsJson != null
          ? FreightDetails(
              type: freightDetailsJson['type'],
              vehicleNumber: freightDetailsJson['vehicle_number'] ?? freightDetailsJson['vehicleNumber'],
              vehicleName: freightDetailsJson['vehicle_name'] ?? freightDetailsJson['vehicleName'],
              driverName: freightDetailsJson['driver_name'] ?? freightDetailsJson['driverName'],
              driverPhone: freightDetailsJson['driver_phone'] ?? freightDetailsJson['driverPhone'],
              ratePer1000: ((freightDetailsJson['rate_per_1000'] ?? freightDetailsJson['ratePer1000']) as num?)?.toDouble() ?? 0.0,
            )
          : null,
      totalAmount: ((json['total_amount'] ?? json['totalAmount']) as num).toDouble(),
      finalAmount: ((json['final_amount'] ?? json['finalAmount']) as num).toDouble(),
      remarks: json['remarks'],
      otp: json['otp'],
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
    );
  }
}

