import 'package:hive/hive.dart';

part 'name_model.g.dart'; // run build_runner to generate adapter

@HiveType(typeId: 0)
class NameModel extends HiveObject {
  @HiveField(0)
  String displayName;

  @HiveField(1)
  String group;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  String? gstin;

  @HiveField(4)
  double? commissionPercent;

  @HiveField(5)
  bool synced;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? serverId; // ID from backend after sync

  NameModel({
    required this.displayName,
    required this.group,
    this.phone,
    this.gstin,
    this.commissionPercent,
    this.synced = false,
    DateTime? createdAt,
    this.serverId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "display_name": displayName,
        "group": group,
        "phone": phone,
        "gstin": gstin,
        "commission_percent": commissionPercent,
      };

  factory NameModel.fromJson(Map<String, dynamic> json) {
    return NameModel(
      displayName: json['display_name'] ?? '',
      group: json['group'] ?? '',
      phone: json['phone'],
      gstin: json['gstin'],
      commissionPercent: json['commission_percent']?.toDouble(),
      synced: true, // If coming from server, it's synced
      serverId: json['id']?.toString(),
    );
  }

  // Convert to UserModel for compatibility with existing code
  Map<String, dynamic> toUserModelJson() => {
        'id': serverId ?? createdAt.millisecondsSinceEpoch.toString(),
        'name': displayName,
        'nameHindi': displayName, // For now, same as display name
        'role': group,
        'roleHindi': _getRoleHindi(group),
        'isActive': true,
        'initials': _computeInitials(displayName),
        'contactPerson': null,
        'phoneNumber': phone,
        'address': null,
        'partyType': _getPartyType(group),
        'gstNumber': gstin,
        'openingBalance': null,
        'openingBalanceType': null,
        'creditLimit': null,
      };

  String _getRoleHindi(String role) {
    switch (role.toLowerCase()) {
      case 'labour':
        return 'लेबर';
      case 'thekedaar':
        return 'ठेकेदार';
      case 'employee':
        return 'कर्मचारी';
      case 'sale':
        return 'बिक्री';
      case 'purchase':
        return 'खरीद';
      case 'general':
        return 'सामान्य';
      default:
        return role;
    }
  }

  String _getPartyType(String group) {
    switch (group.toLowerCase()) {
      case 'labour':
      case 'thekedaar':
      case 'employee':
        return 'Customer';
      case 'sale':
      case 'purchase':
        return 'Supplier';
      default:
        return 'Customer';
    }
  }

  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
