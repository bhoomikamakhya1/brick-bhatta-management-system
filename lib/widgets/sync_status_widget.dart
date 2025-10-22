import 'package:flutter/material.dart';
import '../services/user_sync_bridge.dart';

class SyncStatusWidget extends StatefulWidget {
  final VoidCallback? onSyncPressed;
  
  const SyncStatusWidget({super.key, this.onSyncPressed});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  Map<String, int> _syncStatus = {'total': 0, 'synced': 0, 'pending': 0};
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _updateSyncStatus();
  }

  void _updateSyncStatus() {
    setState(() {
      _syncStatus = UserSyncBridge.getSyncStatus();
    });
  }

  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await UserSyncBridge.forceSync();
      _updateSyncStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sync completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _syncStatus['pending'] ?? 0;
    final totalCount = _syncStatus['total'] ?? 0;
    final syncedCount = _syncStatus['synced'] ?? 0;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  pendingCount > 0 ? Icons.sync_problem : Icons.sync,
                  color: pendingCount > 0 ? Colors.orange : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sync Status',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (_isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _performSync,
                    tooltip: 'Force Sync',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip('Total', totalCount, Colors.blue),
                const SizedBox(width: 8),
                _buildStatusChip('Synced', syncedCount, Colors.green),
                const SizedBox(width: 8),
                _buildStatusChip('Pending', pendingCount, Colors.orange),
              ],
            ),
            if (pendingCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ $pendingCount items pending sync',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
