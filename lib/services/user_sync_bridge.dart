import 'package:hive/hive.dart';
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

  /// Add a user to both UserData and sync system (OPTIMIZED)
  static Future<void> addUser(UserModel user) async {
    try {
      print('🔄 UserSyncBridge: Adding user ${user.name}');
      
      // Add to existing UserData (fast local operation)
      UserData.addUser(user);
      print('✅ UserSyncBridge: Added to UserData');
      
      // Optimized: Direct Hive box access for faster operations
      final box = await Hive.openBox<NameModel>('names');
      final name = userToName(user);
      print('🔄 UserSyncBridge: Converting to NameModel: ${name.displayName}');
      
      await box.add(name);
      print('✅ UserSyncBridge: Added to sync system');
      
    } catch (e) {
      print('❌ UserSyncBridge: Error adding user: $e');
      rethrow;
    }
  }

  /// Update a user in both UserData and sync system (OPTIMIZED)
  static Future<void> updateUser(UserModel user) async {
    try {
      print('🔄 UserSyncBridge: Updating user ${user.name}');
      
      // Update in existing UserData (fast local operation)
      UserData.updateUser(user);
      print('✅ UserSyncBridge: Updated in UserData');
      
      // Optimized: Direct Hive box access for faster operations
      final box = await Hive.openBox<NameModel>('names');
      NameModel? matchingName;
      
      // Try to find by user ID first (most reliable) - optimized search
      try {
        matchingName = box.values.firstWhere(
          (name) => name.serverId == user.id || 
                    name.createdAt.millisecondsSinceEpoch.toString() == user.id,
        );
        print('✅ UserSyncBridge: Found existing name by ID');
      } catch (e) {
        // If not found by ID, try by name and role - optimized search
        try {
          matchingName = box.values.firstWhere(
            (name) => name.displayName == user.name && name.group == user.role,
          );
          print('✅ UserSyncBridge: Found existing name by name/role');
        } catch (e) {
          print('⚠️ UserSyncBridge: No existing name found, creating new one');
          // If no matching name found, create a new one and add it
          final newName = userToName(user);
          await box.add(newName);
          print('✅ UserSyncBridge: Added new name to sync system');
          return; // Exit early since we just added a new name
        }
      }
      
      // Update the existing name (optimized - no unnecessary sync)
      if (matchingName != null) {
        matchingName.displayName = user.name;
        matchingName.group = user.role;
        matchingName.phone = user.phoneNumber;
        matchingName.gstin = user.gstNumber;
        
        // Direct save without triggering full sync
        await matchingName.save();
        print('✅ UserSyncBridge: Updated existing name in sync system');
        
        // Mark as unsynced for background sync (non-blocking)
        matchingName.synced = false;
        await matchingName.save();
        print('🔄 UserSyncBridge: Marked for background sync');
      }
      
    } catch (e) {
      print('❌ UserSyncBridge: Error updating user: $e');
      rethrow;
    }
  }

  /// Remove a user from both UserData and sync system (OPTIMIZED)
  static Future<void> removeUser(String userId) async {
    try {
      print('🔄 UserSyncBridge: Removing user $userId');
      
      // Remove from existing UserData (fast local operation)
      UserData.removeUser(userId);
      print('✅ UserSyncBridge: Removed from UserData');
      
      // Optimized: Direct Hive box access for faster operations
      final box = await Hive.openBox<NameModel>('names');
      NameModel? matchingName;
      
      try {
        matchingName = box.values.firstWhere(
          (name) => name.serverId == userId || 
                    name.createdAt.millisecondsSinceEpoch.toString() == userId,
        );
        print('✅ UserSyncBridge: Found name to remove');
        
        // Direct delete without triggering full sync
        await matchingName.delete();
        print('✅ UserSyncBridge: Removed from sync system');
        
      } catch (e) {
        print('⚠️ UserSyncBridge: No matching name found in sync system: $e');
        // Continue anyway since the user was removed from UserData
      }
      
    } catch (e) {
      print('❌ UserSyncBridge: Error removing user: $e');
      rethrow;
    }
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

  /// Force sync all pending changes (background operation)
  static Future<void> forceSync() async {
    try {
      print('🔄 UserSyncBridge: Starting background sync');
      await SyncService.syncNames();
      await SyncService.pullFromBackend();
      print('✅ UserSyncBridge: Background sync completed');
    } catch (e) {
      print('❌ UserSyncBridge: Background sync failed: $e');
      // Don't rethrow - background sync failures shouldn't crash the app
    }
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
