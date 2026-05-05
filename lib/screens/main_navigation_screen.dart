import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sale_data_service.dart';
import '../services/user_sync_bridge.dart';
import '../services/work_data_service.dart';
import '../data/user_data.dart';
import 'dashboard_screen.dart' show DashboardScreen, DashboardScreenState;
import 'ledger_screen.dart';
import 'transactions_screen.dart';
import 'work_list_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<State<DashboardScreen>> _dashboardKey = GlobalKey<State<DashboardScreen>>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load user data from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole') ?? '';
    final userPhone = prefs.getString('userPhone') ?? '';
    
    // Set in UserData for global access
    UserData.setCurrentUserRole(userRole);
    UserData.setCurrentUserPhone(userPhone);
    
    print('✅ [MAIN] User role loaded: $userRole');
    print('✅ [MAIN] User phone loaded: $userPhone');
    
    // Fetch data from backend on startup
    await Future.wait([
      SaleDataService.fetchSales(),
      UserSyncBridge.fetchAndSyncUsers(),
      WorkDataService.fetchWorkEntries(),
    ]);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> get _screens => [
    DashboardScreen(
      key: _dashboardKey,
      onNavigateToReports: () {
        setState(() {
          _currentIndex = 4; // Reports tab index
        });
      },
    ),
    const WorkListScreen(),
    const LedgerScreen(),
    const TransactionsScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)))
        : IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.build,
                  label: 'Work',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.groups,
                  label: 'Ledger',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.swap_horiz,
                  label: 'Trans',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.assessment,
                  label: 'Reports',
                  index: 4,
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  index: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          // Refresh dashboard when navigating to home tab
          if (index == 0 && _dashboardKey.currentState != null) {
            final dashboardState = _dashboardKey.currentState;
            if (dashboardState is DashboardScreenState) {
              dashboardState.refreshStats();
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: isSelected
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.grey, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}