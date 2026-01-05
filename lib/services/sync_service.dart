import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../models/name_model.dart';
import 'api_service.dart';

class SyncService {
  static const String _namesBoxName = 'names';

  /// Initialize the sync service and open Hive boxes
  static Future<void> initialize() async {
    await Hive.openBox<NameModel>(_namesBoxName);
  }

  /// Check if device is online
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Sync all unsynced names to the backend
  static Future<void> syncNames() async {
    final isOnline = await SyncService.isOnline();
    if (!isOnline) {
      print("📴 Offline — data will sync later.");
      return;
    }

    print("🔁 Syncing unsynced names...");
    
    // Test backend connection first
    await ApiService.testConnection();
    await ApiService.testNamesEndpoint();
    
    final box = Hive.box<NameModel>(_namesBoxName);
    
    final unsyncedNames = box.values.where((n) => !n.synced).toList();
    
    if (unsyncedNames.isEmpty) {
      print("✅ All names are synced");
      return;
    }
    
    print("📤 Attempting to sync ${unsyncedNames.length} name(s)...");
    
    for (var name in unsyncedNames) {
      try {
        final response = await ApiService.sendName(name);
        if (response != null) {
          // Update the name with server ID and mark as synced
          name.serverId = response['server_id']?.toString() ?? response['id']?.toString();
          name.synced = true;
          await name.save();
          print("✅ Synced: ${name.displayName}");
        } else {
          print("❌ Failed to sync: ${name.displayName} (check logs above for details)");
          // Stop syncing if we can't connect to the server to avoid spamming errors
          // The remaining items will be synced on next attempt
          break;
        }
      } catch (e) {
        print("❌ Error syncing ${name.displayName}: $e");
        // Stop syncing on error to avoid spamming
        break;
      }
    }
  }

  /// Pull latest data from backend and merge with local data
  static Future<void> pullFromBackend() async {
    final isOnline = await SyncService.isOnline();
    if (!isOnline) {
      print("📴 Offline — cannot pull from backend.");
      return;
    }

    print("📥 Pulling latest data from backend...");
    try {
      final serverNames = await ApiService.fetchNames();
      final box = Hive.box<NameModel>(_namesBoxName);
      
      // Create a map of existing names by server ID for quick lookup
      final existingNames = <String, NameModel>{};
      for (var name in box.values) {
        if (name.serverId != null) {
          existingNames[name.serverId!] = name;
        }
      }

      // Process server data
      for (var serverName in serverNames) {
        if (serverName.serverId != null) {
          final existing = existingNames[serverName.serverId!];
          if (existing == null) {
            // New name from server - add it
            await box.add(serverName);
            print("📥 Added new name from server: ${serverName.displayName}");
          } else {
            // Update existing name if server version is newer
            if (serverName.createdAt.isAfter(existing.createdAt)) {
              existing.displayName = serverName.displayName;
              existing.group = serverName.group;
              existing.phone = serverName.phone;
              existing.gstin = serverName.gstin;
              existing.commissionPercent = serverName.commissionPercent;
              existing.synced = true;
              await existing.save();
              print("🔄 Updated name from server: ${serverName.displayName}");
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error pulling from backend: $e");
    }
  }

  /// Add a new name locally and attempt to sync
  static Future<void> addName(NameModel name) async {
    try {
      print('🔄 SyncService: Adding name ${name.displayName}');
      
      final box = Hive.box<NameModel>(_namesBoxName);
      await box.add(name);
      print('✅ SyncService: Added to local storage');
      
      // Try to sync immediately if online
      await syncNames();
      print('✅ SyncService: Sync attempt completed');
      
    } catch (e) {
      print('❌ SyncService: Error adding name: $e');
      rethrow;
    }
  }

  /// Update an existing name and sync to backend
  static Future<void> updateName(NameModel name) async {
    try {
      print('🔄 SyncService: Updating name ${name.displayName}');
      
      // Check if the name is properly associated with a box
      if (!name.isInBox) {
        print('⚠️ SyncService: Name not in box, skipping update');
        return;
      }
      
      await name.save();
      print('✅ SyncService: Saved name locally');
      
      // If it has a server ID, try to sync to backend
      if (name.serverId != null) {
        final isOnline = await SyncService.isOnline();
        if (isOnline) {
          final success = await ApiService.updateName(name);
          if (success) {
            name.synced = true;
            await name.save();
            print('✅ SyncService: Synced to backend');
          } else {
            print('⚠️ SyncService: Failed to sync to backend');
          }
        } else {
          print('📴 SyncService: Offline, will sync later');
        }
      } else {
        // If no server ID, it's a local change that needs to be synced
        print('🔄 SyncService: No server ID, attempting sync');
        await syncNames();
      }
      
    } catch (e) {
      print('❌ SyncService: Error updating name: $e');
      rethrow;
    }
  }

  /// Delete a name locally and from backend
  static Future<void> deleteName(NameModel name) async {
    final box = Hive.box<NameModel>(_namesBoxName);
    
    // If it has a server ID, delete from backend first
    if (name.serverId != null) {
      final isOnline = await SyncService.isOnline();
      if (isOnline) {
        final success = await ApiService.deleteName(name.serverId!);
        if (success) {
          await name.delete();
          print("🗑️ Deleted name from server: ${name.displayName}");
        } else {
          print("❌ Failed to delete from server: ${name.displayName}");
        }
      } else {
        // Mark for deletion when online
        name.synced = false; // This will trigger a re-sync attempt
        await name.save();
        await name.delete();
      }
    } else {
      // Local only - just delete
      await name.delete();
    }
  }

  /// Get all names from local storage
  static List<NameModel> getAllNames() {
    final box = Hive.box<NameModel>(_namesBoxName);
    return box.values.toList();
  }

  /// Get names by group
  static List<NameModel> getNamesByGroup(String group) {
    final box = Hive.box<NameModel>(_namesBoxName);
    return box.values.where((name) => name.group.toLowerCase() == group.toLowerCase()).toList();
  }

  /// Clear all local data
  static Future<void> clearAllData() async {
    final box = Hive.box<NameModel>(_namesBoxName);
    await box.clear();
    print("🗑️ Cleared all local data");
  }

  /// Get sync status summary
  static Map<String, int> getSyncStatus() {
    final box = Hive.box<NameModel>(_namesBoxName);
    final allNames = box.values.toList();
    
    return {
      'total': allNames.length,
      'synced': allNames.where((n) => n.synced).length,
      'pending': allNames.where((n) => !n.synced).length,
    };
  }
}
