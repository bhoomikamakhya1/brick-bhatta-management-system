import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/user_data.dart';
import 'add_user_screen.dart';
import '../widgets/user_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/filter_chip.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Workers', 'Supervisors', 'Managers'];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF333333)),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                StatsCard(
                  title: 'Total Users',
                  titleHindi: 'कुल उपयोगकर्ता',
                  value: UserData.getTotalUsers().toString(),
                  icon: Icons.people,
                ),
                StatsCard(
                  title: 'Active Workers',
                  titleHindi: 'सक्रिय कर्मचारी',
                  value: UserData.getActiveWorkers().toString(),
                  icon: Icons.work,
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                return CustomFilterChip(
                  label: filter,
                  isSelected: selectedFilter == filter,
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return UserCard(
                  user: user,
                  onTap: () {
                    // TODO: Navigate to user details
                    _showUserDetails(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_user_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddUserScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<UserModel> _getFilteredUsers() {
    switch (selectedFilter) {
      case 'Workers':
        return UserData.getUsersByRole('Worker');
      case 'Supervisors':
        return UserData.getUsersByRole('Supervisor');
      case 'Managers':
        return UserData.getUsersByRole('Manager');
      default:
        return UserData.getUsers();
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hindi Name: ${user.nameHindi}'),
            Text('Role: ${user.role} (${user.roleHindi})'),
            Text('ID: ${user.id}'),
            Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
