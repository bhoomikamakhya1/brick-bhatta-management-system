import 'package:flutter/material.dart';
import '../data/user_data.dart';

class LabourWork {
  final String id;
  final String labourName;
  final String labourCategory;
  final double quantity;
  final double? percentage;
  final double rate;
  final double totalAmount;
  final DateTime date;
  final bool synced;
  final String? serverId;

  LabourWork({
    required this.id,
    required this.labourName,
    required this.labourCategory,
    required this.quantity,
    this.percentage,
    required this.rate,
    required this.totalAmount,
    required this.date,
    this.synced = false,
    this.serverId,
  });

  factory LabourWork.fromJson(Map<String, dynamic> json) {
    // Handle both snake_case (from backend) and camelCase (from local storage)
    return LabourWork(
      id: json['id'],
      labourName: json['labour_name'] ?? json['labourName'] ?? '',
      labourCategory: json['labour_category'] ?? json['labourCategory'] ?? '',
      quantity: (json['quantity'] is num) ? json['quantity'].toDouble() : 0.0,
      percentage: json['percentage'] != null ? (json['percentage'] as num).toDouble() : null,
      rate: (json['rate'] is num) ? json['rate'].toDouble() : 0.0,
      totalAmount: (json['total_amount'] ?? json['totalAmount']) != null
          ? ((json['total_amount'] ?? json['totalAmount']) as num).toDouble()
          : 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      synced: json['synced'] ?? false,
      serverId: json['server_id'] ?? json['serverId'] ?? json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    // Convert to snake_case for backend API compatibility
    return {
      'id': id,
      'labour_name': labourName,
      'labour_category': labourCategory,
      'quantity': quantity,
      'percentage': percentage,
      'rate': rate,
      'total_amount': totalAmount,
      'date': date.toIso8601String(),
      // Note: synced and serverId are client-side only, don't send to backend
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
  // Mapping of labour names to thekedar names
  static Map<String, String> _labourToThekedar = {
    'राम कुमार': 'राम कुमार',
    'मोहन लाल': 'मोहन लाल',
    'सुरेश गुप्ता': 'सुरेश गुप्ता',
    'अमित सिंह': 'अमित सिंह',
    'राजेश कुमार': 'राजेश कुमार',
    'प्रिया शर्मा': 'राम कुमार',
    'रवि वर्मा': 'मोहन लाल',
  };

  // Mapping of labour names to rates (from ledger entries)
  static Map<String, double> _labourToRate = {
    'राम कुमार': 450.0,
    'मोहन लाल': 40.0,
    'सुरेश गुप्ता': 450.0,
    'अमित सिंह': 450.0,
    'राजेश कुमार': 450.0,
    'प्रिया शर्मा': 450.0,
    'रवि वर्मा': 450.0,
  };

  // Get rate for a specific labour name
  static double getRateForLabour(String labourName) {
    return _labourToRate[labourName] ?? getDefaultRate();
  }

  // Set rate for a specific labour name (for ledger entries)
  static void setRateForLabour(String labourName, double rate) {
    _labourToRate[labourName] = rate;
  }

  // Set thekedar mapping for a labour name
  static void setLabourThekedarMapping(String labourName, String thekedarName) {
    _labourToThekedar[labourName] = thekedarName;
  }

  // Get all labour rates
  static Map<String, double> getAllLabourRates() {
    return Map.from(_labourToRate);
  }

  static List<String> getLabourNames({String? labourType}) {
    // Get labour names dynamically from UserData
    final labourUsers = UserData.getUsersByRole('Labour');
    
    // Filter by labour type if provided (labour type is stored in partyType field)
    List<String> labourNames;
    if (labourType != null) {
      labourNames = labourUsers
          .where((user) => user.partyType == labourType)
          .map((user) => user.name)
          .toList();
    } else {
      labourNames = labourUsers.map((user) => user.name).toList();
    }
    
    // Merge with existing static names to ensure backward compatibility
    // Note: Static names don't have labour type filtering, so only include them if no type filter is applied
    if (labourType == null) {
      final staticNames = [
        'राम कुमार',
        'मोहन लाल',
        'सुरेश गुप्ता',
        'अमित सिंह',
        'राजेश कुमार',
        'प्रिया शर्मा',
        'रवि वर्मा',
      ];
      
      // Combine and remove duplicates
      final allNames = <String>{...staticNames, ...labourNames};
      return allNames.toList()..sort();
    }
    
    return labourNames..sort();
  }

  // Get labour names filtered by thekedar and optionally by labour type
  static List<String> getLabourNamesByThekedar(String? thekedarName, {String? labourType}) {
    if (thekedarName == null || thekedarName.isEmpty) {
      return getLabourNames(labourType: labourType);
    }
    
    // Get labours from UserData that match both thekedar and labour type
    final labourUsers = UserData.getUsersByRole('Labour');
    final thekedarLabours = _labourToThekedar.entries
        .where((entry) => entry.value == thekedarName)
        .map((entry) => entry.key)
        .toSet();
    
    // Filter by labour type if provided
    final filteredLabours = labourUsers
        .where((user) {
          final matchesThekedar = thekedarLabours.contains(user.name);
          final matchesType = labourType == null || user.partyType == labourType;
          return matchesThekedar && matchesType;
        })
        .map((user) => user.name)
        .toList();
    
    // Also check static mapping (for backward compatibility, only if no type filter)
    if (labourType == null) {
      final staticLabours = _labourToThekedar.entries
          .where((entry) => entry.value == thekedarName)
          .map((entry) => entry.key)
          .where((name) => !filteredLabours.contains(name))
          .toList();
      filteredLabours.addAll(staticLabours);
    }
    
    return filteredLabours..sort();
  }

  // Get all unique thekedar names, optionally filtered by labour type
  static List<String> getThekedarNames({String? labourType}) {
    if (labourType == null) {
      // No filter: return all thekedars from mapping and UserData
      final thekedarUsers = UserData.getUsersByRole('Thekedaar');
      final thekedarNamesFromUsers = thekedarUsers.map((user) => user.name).toSet();
      final thekedarNamesFromMapping = _labourToThekedar.values.toSet();
      final allThekedarNames = <String>{...thekedarNamesFromUsers, ...thekedarNamesFromMapping};
      return allThekedarNames.toList()..sort();
    }
    
    // Filter: only return thekedars who have at least one labour of the specified type
    final labourUsers = UserData.getUsersByRole('Labour');
    final laboursOfType = labourUsers
        .where((user) => user.partyType == labourType)
        .map((user) => user.name)
        .toSet();
    
    // Get thekedars from the mapping who have labours of this type
    final thekedarSet = <String>{};
    for (var entry in _labourToThekedar.entries) {
      if (laboursOfType.contains(entry.key)) {
        thekedarSet.add(entry.value);
      }
    }
    
    // Debug output to help diagnose issues
    print('🔍 [LabourData.getThekedarNames] Filtering for labour type: $labourType');
    print('🔍 [LabourData.getThekedarNames] Total labour users: ${labourUsers.length}');
    print('🔍 [LabourData.getThekedarNames] Labours of type $labourType: $laboursOfType');
    print('🔍 [LabourData.getThekedarNames] Mapping entries: ${_labourToThekedar.length}');
    print('🔍 [LabourData.getThekedarNames] Thekedars found: $thekedarSet');
    
    // Also include thekedars from UserData that might not be in the mapping yet
    // (For backward compatibility, include them if we have no way to filter)
    // Actually, to be safe, only return thekedars that we know have labours of this type
    return thekedarSet.toList()..sort();
  }



  static double getDefaultRate() {
    return 450.00;
  }
}
