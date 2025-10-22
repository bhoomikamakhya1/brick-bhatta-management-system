import 'package:flutter/material.dart';

class LabourWork {
  final String id;
  final String labourName;
  final String labourCategory;
  final double quantity;
  final double? percentage;
  final double rate;
  final double totalAmount;
  final DateTime date;

  LabourWork({
    required this.id,
    required this.labourName,
    required this.labourCategory,
    required this.quantity,
    this.percentage,
    required this.rate,
    required this.totalAmount,
    required this.date,
  });

  factory LabourWork.fromJson(Map<String, dynamic> json) {
    return LabourWork(
      id: json['id'],
      labourName: json['labourName'],
      labourCategory: json['labourCategory'],
      quantity: json['quantity'].toDouble(),
      percentage: json['percentage']?.toDouble(),
      rate: json['rate'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labourName': labourName,
      'labourCategory': labourCategory,
      'quantity': quantity,
      'percentage': percentage,
      'rate': rate,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
    };
  }
}

class LabourCategory {
  final String id;
  final String name;
  final Color color;

  LabourCategory({
    required this.id,
    required this.name,
    required this.color,
  });
}

class LabourData {
  static List<String> getLabourNames() {
    return [
      'राम कुमार',
      'मोहन लाल',
      'सुरेश गुप्ता',
      'अमित सिंह',
      'राजेश कुमार',
      'प्रिया शर्मा',
      'रवि वर्मा',
    ];
  }

  static List<LabourCategory> getLabourCategories() {
    return [
      LabourCategory(
        id: '1',
        name: 'Group A',
        color: const Color(0xFF8B4513), // Dark brown/orange
      ),
      LabourCategory(
        id: '2',
        name: 'Mason',
        color: const Color(0xFF4A90A4), // Teal/blue-grey
      ),
      LabourCategory(
        id: '3',
        name: 'Rajesh Contractor',
        color: const Color(0xFF9E9E9E), // Light grey
      ),
    ];
  }

  static double getDefaultRate() {
    return 450.00;
  }
}
