import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data.dart';
import '../models/user_model.dart';
import '../services/user_sync_bridge.dart';
import '../widgets/sync_status_widget.dart';
import 'add_party_screen.dart';
import 'ledger_detail_screen.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Labour', 'Thekedaar', 'Employee', 'Sale'];
  String _selectedFilter = 'All';

  String? _currentUserPhone;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    
    // Initialize sync on screen load
    _initializeSync();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeSync() async {
    // Get current user phone for filtering
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserPhone = prefs.getString('userPhone') ?? '';
    });

    // Sync existing users to the sync system
    await UserSyncBridge.syncUsersToNames();
    
    // Try to sync with backend
    await UserSyncBridge.forceSync();
    
    if (mounted) {
      setState(() {});
    }
  }

  List<UserModel> _getFilteredUsers() {
    final query = _searchController.text.trim().toLowerCase();
    var all = UserData.getUsers();

    // Filter out current user
    if (_currentUserPhone != null && _currentUserPhone!.isNotEmpty) {
      final currentPhone = _currentUserPhone!.replaceAll(' ', '');
      all = all.where((u) {
        final uPhone = (u.phoneNumber ?? '').replaceAll(' ', '');
        return uPhone != currentPhone;
      }).toList();
    }

    final roleFiltered = _selectedFilter == 'All'
        ? all
        : all.where((u) => u.role.toLowerCase() == _selectedFilter.toLowerCase()).toList();

    if (query.isEmpty) return roleFiltered;
    return roleFiltered
        .where((u) => u.name.toLowerCase().contains(query) || u.nameHindi.toLowerCase().contains(query))
        .toList();
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'labour':
        return 'Labour';
      case 'thekedaar':
        return 'Thekedaar';
      case 'employee':
        return 'Employee';
      case 'sale':
        return 'Sale';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ledger / खाता',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: 'Clear',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Ledger'),
                  content: const Text('This will remove all parties from the ledger. Continue?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                  ],
                ),
              );
              if (confirmed == true) {
                await UserSyncBridge.clearAllUsers();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sync Status Widget
          // const SyncStatusWidget(),
          
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search Party / नाम खोजें',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
          ),

          // Filters
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _filters[index];
                final selected = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFF9800) : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return _LedgerListItem(
                  user: u,
                  onDeleted: () => setState(() {}),
                  onUpdated: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_party_fab",
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddPartyScreen()))
              .then((_) => setState(() {}));
        },
        backgroundColor: const Color(0xFFFF6F00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}

class _LedgerListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const _LedgerListItem({required this.user, this.onDeleted, this.onUpdated});

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'labour':
        return const Color(0xFF2196F3); // Light blue
      case 'thekedaar':
        return const Color(0xFFFF9800); // Light orange
      case 'employee':
        return const Color(0xFF9C27B0); // Light purple
      case 'sale':
        return const Color(0xFF4CAF50); // Light green
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'labour':
        return 'Labour';
      case 'thekedaar':
        return 'Thekedaar';
      case 'employee':
        return 'Employee';
      case 'sale':
        return 'Sale';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.nameHindi,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 2),
            Text(
              user.name,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleColor(user.role).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: TextStyle(
                      color: _roleColor(user.role),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFBE9E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.isActive ? const Color(0xFF2E7D32) : const Color(0xFFBF360C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 20),
        onTap: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => LedgerDetailScreen(user: user),
                ),
              )
              .then((result) async {
            if (result is UserModel) {
              // User was updated in the detail screen, just refresh the UI
              onUpdated?.call();
            }
          });
        },
        onLongPress: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Party'),
              content: Text('Delete ${user.name}?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
              ],
            ),
          );
          if (confirmed == true) {
            await UserSyncBridge.removeUser(user.id);
            onDeleted?.call();
          }
        },
      ),
    );
  }
}


