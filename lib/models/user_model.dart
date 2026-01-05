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
    // Handle both snake_case (from backend) and camelCase (from local storage)
    return UserModel(
      id: json['id'],
      name: json['name'],
      nameHindi: json['name_hindi'] ?? json['nameHindi'] ?? '',
      role: json['role'],
      roleHindi: json['role_hindi'] ?? json['roleHindi'] ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      initials: json['initials'],
      contactPerson: json['contact_person'] ?? json['contactPerson'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      address: json['address'],
      partyType: json['party_type'] ?? json['partyType'],
      gstNumber: json['gst_number'] ?? json['gstNumber'],
      openingBalance: (json['opening_balance'] ?? json['openingBalance']) != null 
          ? ((json['opening_balance'] ?? json['openingBalance']) as num).toDouble() 
          : null,
      openingBalanceType: json['opening_balance_type'] ?? json['openingBalanceType'],
      creditLimit: (json['credit_limit'] ?? json['creditLimit']) != null
          ? ((json['credit_limit'] ?? json['creditLimit']) as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert to snake_case for backend API compatibility
    return {
      'id': id,
      'name': name,
      'name_hindi': nameHindi,
      'role': role,
      'role_hindi': roleHindi,
      'is_active': isActive,
      'initials': initials,
      'contact_person': contactPerson,
      'phone_number': phoneNumber,
      'address': address,
      'party_type': partyType,
      'gst_number': gstNumber,
      'opening_balance': openingBalance,
      'opening_balance_type': openingBalanceType,
      'credit_limit': creditLimit,
    };
  }
}

enum UserRole {
  admin,
  pakkaMuneem,
  kacchaMuneem,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.pakkaMuneem:
        return 'Pakka Muneem';
      case UserRole.kacchaMuneem:
        return 'Kaccha Muneem';
    }
  }

  String get displayNameHindi {
    switch (this) {
      case UserRole.admin:
        return 'एडमिन';
      case UserRole.pakkaMuneem:
        return 'पक्का मुनीम';
      case UserRole.kacchaMuneem:
        return 'कच्चा मुनीम';
    }
  }
}
