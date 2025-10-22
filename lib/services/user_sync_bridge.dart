import '../models/user_model.dart';
import '../models/name_model.dart';
import '../data/user_data.dart';
import 'sync_service.dart';

class UserSyncBridge {
  /// Convert UserModel to NameModel for sync
  static NameModel userToName(UserModel user) {
    return NameModel(
      displayName: user.name,
      group: user.role,
      phone: user.phoneNumber,
      gstin: user.gstNumber,
      commissionPercent: null, // Could be extracted from user data if available
      synced: false, // Will be determined by sync status
      createdAt: DateTime.now(),
    );
  }

  /// Convert NameModel to UserModel for compatibility
  static UserModel nameToUser(NameModel name) {
    return UserModel(
      id: name.serverId ?? name.createdAt.millisecondsSinceEpoch.toString(),
      name: name.displayName,
      nameHindi: name.displayName, // For now, same as display name
      role: name.group,
      roleHindi: _getRoleHindi(name.group),
      isActive: true,
      initials: _computeInitials(name.displayName),
      contactPerson: null,
      phoneNumber: name.phone,
      address: null,
      partyType: _getPartyType(name.group),
      gstNumber: name.gstin,
      openingBalance: null,
      openingBalanceType: null,
      creditLimit: null,
    );
  }

  /// Sync all users from UserData to the sync system
  static Future<void> syncUsersToNames() async {
    final users = UserData.getUsers();
    
    for (var user in users) {
      final name = userToName(user);
      await SyncService.addName(name);
    }
    
    print("🔄 Synced ${users.length} users to sync system");
  }

  /// Get all users from sync system as UserModels
  static List<UserModel> getUsersFromSync() {
    final names = SyncService.getAllNames();
    return names.map((name) => nameToUser(name)).toList();
  }

  /// Add a user to both UserData and sync system
  static Future<void> addUser(UserModel user) async {
    // Add to existing UserData
    UserData.addUser(user);
    
    // Add to sync system
    final name = userToName(user);
    await SyncService.addName(name);
  }

  /// Update a user in both UserData and sync system
  static Future<void> updateUser(UserModel user) async {
    // Update in existing UserData
    UserData.updateUser(user);
    
    // Find corresponding name in sync system and update
    final names = SyncService.getAllNames();
    final matchingName = names.firstWhere(
      (name) => name.displayName == user.name && name.group == user.role,
      orElse: () => userToName(user),
    );
    
    matchingName.displayName = user.name;
    matchingName.group = user.role;
    matchingName.phone = user.phoneNumber;
    matchingName.gstin = user.gstNumber;
    
    await SyncService.updateName(matchingName);
  }

  /// Remove a user from both UserData and sync system
  static Future<void> removeUser(String userId) async {
    // Remove from existing UserData
    UserData.removeUser(userId);
    
    // Find and remove from sync system
    final names = SyncService.getAllNames();
    final matchingName = names.firstWhere(
      (name) => name.serverId == userId || 
                name.createdAt.millisecondsSinceEpoch.toString() == userId,
      orElse: () => throw Exception('User not found in sync system'),
    );
    
    await SyncService.deleteName(matchingName);
  }

  /// Clear all users from both systems
  static Future<void> clearAllUsers() async {
    UserData.clear();
    await SyncService.clearAllData();
  }

  /// Get sync status for users
  static Map<String, int> getSyncStatus() {
    return SyncService.getSyncStatus();
  }

  /// Force sync all pending changes
  static Future<void> forceSync() async {
    await SyncService.syncNames();
    await SyncService.pullFromBackend();
  }

  // Helper methods
  static String _getRoleHindi(String role) {
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

  static String _getPartyType(String group) {
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

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
