import 'package:flutter/material.dart';

class CommissionEntry {
  final String id;
  final String thekedaarName;
  final String thekedaarType;
  final DateTime fromDate;
  final DateTime toDate;
  final double baseAmount;
  final double commissionPercentage;
  final double commissionAmount;

  CommissionEntry({
    required this.id,
    required this.thekedaarName,
    required this.thekedaarType,
    required this.fromDate,
    required this.toDate,
    required this.baseAmount,
    required this.commissionPercentage,
    required this.commissionAmount,
  });

  factory CommissionEntry.fromJson(Map<String, dynamic> json) {
    return CommissionEntry(
      id: json['id'],
      thekedaarName: json['thekedaarName'],
      thekedaarType: json['thekedaarType'],
      fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      baseAmount: json['baseAmount'].toDouble(),
      commissionPercentage: json['commissionPercentage'].toDouble(),
      commissionAmount: json['commissionAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thekedaarName': thekedaarName,
      'thekedaarType': thekedaarType,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'baseAmount': baseAmount,
      'commissionPercentage': commissionPercentage,
      'commissionAmount': commissionAmount,
    };
  }
}

class Thekedaar {
  final String id;
  final String name;
  final String type;

  Thekedaar({
    required this.id,
    required this.name,
    required this.type,
  });
}

class CommissionData {
  static List<Thekedaar> getThekedaars() {
    return [
      Thekedaar(id: '1', name: 'राम कुमार', type: 'Pathai'),
      Thekedaar(id: '2', name: 'मोहन लाल', type: 'Bharai'),
      Thekedaar(id: '3', name: 'सुरेश गुप्ता', type: 'Pathai'),
      Thekedaar(id: '4', name: 'अमित सिंह', type: 'Bharai'),
      Thekedaar(id: '5', name: 'राजेश कुमार', type: 'Pathai'),
    ];
  }

  static List<CommissionEntry> getRecentEntries() {
    return [
      CommissionEntry(
        id: '1',
        thekedaarName: 'राम कुमार',
        thekedaarType: 'Pathai',
        fromDate: DateTime(2024, 12, 1),
        toDate: DateTime(2024, 12, 15),
        baseAmount: 25000,
        commissionPercentage: 5.0,
        commissionAmount: 1250,
      ),
      CommissionEntry(
        id: '2',
        thekedaarName: 'मोहन लाल',
        thekedaarType: 'Bharai',
        fromDate: DateTime(2024, 12, 1),
        toDate: DateTime(2024, 12, 14),
        baseAmount: 20000,
        commissionPercentage: 4.0,
        commissionAmount: 800,
      ),
    ];
  }
}
