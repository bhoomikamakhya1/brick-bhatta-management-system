import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/name_model.dart';
import '../services/sync_service.dart';
import '../services/user_sync_bridge.dart';

class SyncDemoScreen extends StatefulWidget {
  const SyncDemoScreen({super.key});

  @override
  State<SyncDemoScreen> createState() => _SyncDemoScreenState();
}

class _SyncDemoScreenState extends State<SyncDemoScreen> {
  final _nameController = TextEditingController();
  final _groupController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addName() async {
    if (_nameController.text.trim().isEmpty) return;

    final groupInput = _groupController.text.trim().isEmpty ? 'General' : _groupController.text.trim();
    final mappedGroup = UserSyncBridge.mapRoleToBackendGroup(groupInput);

    final name = NameModel(
      displayName: _nameController.text.trim(),
      group: mappedGroup,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );

    await SyncService.addName(name);
    
    _nameController.clear();
    _groupController.clear();
    _phoneController.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name added and synced!')),
      );
    }
  }

  Future<void> _forceSync() async {
    await UserSyncBridge.forceSync();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Demo'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add new name form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _groupController,
                      decoration: const InputDecoration(
                        labelText: 'Group (Labour, Thekedaar, etc.)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add & Sync'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sync controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _forceSync,
                    icon: const Icon(Icons.sync),
                    label: const Text('Force Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await SyncService.clearAllData();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Names list
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<NameModel>('names').listenable(),
                builder: (context, box, _) {
                  final names = box.values.toList();
                  
                  if (names.isEmpty) {
                    return const Center(
                      child: Text('No names added yet. Add some names above!'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      final name = names[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(name.displayName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Group: ${name.group}'),
                              if (name.phone != null) Text('Phone: ${name.phone}'),
                              Text(
                                name.synced ? '✅ Synced' : '⏳ Pending',
                                style: TextStyle(
                                  color: name.synced ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await SyncService.deleteName(name);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
