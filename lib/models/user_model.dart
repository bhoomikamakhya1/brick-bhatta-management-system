class UserModel {
  final String id;
  final String name;
  final String nameHindi;
  final String role;
  final String roleHindi;
  final bool isActive;
  final String initials;
  // Optional extended party fields
  final String? contactPerson;
  final String? phoneNumber;
  final String? address;
  final String? partyType; // e.g., Customer/Supplier
  final String? gstNumber;
  final double? openingBalance;
  final String? openingBalanceType; // Dr/Cr
  final double? creditLimit;

  UserModel({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.role,
    required this.roleHindi,
    this.isActive = true,
    required this.initials,
    this.contactPerson,
    this.phoneNumber,
    this.address,
    this.partyType,
    this.gstNumber,
    this.openingBalance,
    this.openingBalanceType,
    this.creditLimit,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      nameHindi: json['nameHindi'],
      role: json['role'],
      roleHindi: json['roleHindi'],
      isActive: json['isActive'] ?? true,
      initials: json['initials'],
      contactPerson: json['contactPerson'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      partyType: json['partyType'],
      gstNumber: json['gstNumber'],
      openingBalance: (json['openingBalance'] is num) ? (json['openingBalance'] as num).toDouble() : null,
      openingBalanceType: json['openingBalanceType'],
      creditLimit: (json['creditLimit'] is num) ? (json['creditLimit'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameHindi': nameHindi,
      'role': role,
      'roleHindi': roleHindi,
      'isActive': isActive,
      'initials': initials,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'address': address,
      'partyType': partyType,
      'gstNumber': gstNumber,
      'openingBalance': openingBalance,
      'openingBalanceType': openingBalanceType,
      'creditLimit': creditLimit,
    };
  }
}

enum UserRole {
  worker,
  supervisor,
  manager,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.worker:
        return 'Worker';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.manager:
        return 'Manager';
    }
  }

  String get displayNameHindi {
    switch (this) {
      case UserRole.worker:
        return 'कर्मचारी';
      case UserRole.supervisor:
        return 'पर्यवेक्षक';
      case UserRole.manager:
        return 'प्रबंधक';
    }
  }
}
