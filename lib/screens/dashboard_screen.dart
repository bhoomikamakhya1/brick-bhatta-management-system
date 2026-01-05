import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../widgets/user_header.dart';
import '../widgets/overview_card.dart';
import '../widgets/quick_action_button.dart';
import '../services/work_data_service.dart';
import '../services/sale_data_service.dart';
import 'work_type_selection_screen.dart';
import 'add_party_screen.dart';
import 'transaction_type_selection_screen.dart';
import 'commission_entry_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToReports;
  
  const DashboardScreen({super.key, this.onNavigateToReports});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  DashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void refreshStats() {
    _loadStats();
  }

  void _loadStats() {
    // Get today's date
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    // Get today's labour entries
    final todayWorkEntries = WorkDataService.getTodayWorkEntries();
    final labourEntries = todayWorkEntries.length;

    // Get today's sales
    final todaySales = SaleDataService.getSalesByDateRange(startOfDay, endOfDay);
    final salesToday = todaySales.fold(0.0, (sum, sale) => sum + sale.finalAmount);

    // Calculate payables (debit transactions - expenses, salaries, purchases)
    // For now, we'll calculate from work entries (labour payments) and purchases
    // This is a simplified calculation - in a real app, you'd have a transaction service
    final allWorkEntries = WorkDataService.getAllWorkEntries();
    final payables = allWorkEntries.fold(0.0, (sum, work) => sum + work.totalAmount);

    // Calculate receivables (credit transactions - sales)
    // Sum of all sales final amounts
    final allSales = SaleDataService.getAllSales();
    final receivables = allSales.fold(0.0, (sum, sale) => sum + sale.finalAmount);

    setState(() {
      _stats = DashboardStats(
        labourEntries: labourEntries,
        salesToday: salesToday,
        payables: payables,
        receivables: receivables,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              const UserHeader(),
              
              const SizedBox(height: 20),
              
              // Today's Overview Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Today's Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Overview Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  children: [
                    OverviewCard(
                      title: 'Labour Entries',
                      titleHindi: 'श्रमिक प्रविष्टियां',
                      value: _stats?.labourEntries.toString() ?? '0',
                      status: 'Today',
                      icon: Icons.groups,
                      iconColor: Color(0xFF8B4513),
                    ),
                    OverviewCard(
                      title: 'Sales Today',
                      titleHindi: 'आज की बिक्री',
                      value: '₹${(_stats?.salesToday ?? 0.0).toStringAsFixed(0)}',
                      status: 'Today',
                      icon: Icons.show_chart,
                      iconColor: Color(0xFF8B4513),
                    ),
                    OverviewCard(
                      title: 'Payables',
                      titleHindi: 'देय राशि',
                      value: '₹${(_stats?.payables ?? 0.0).toStringAsFixed(0)}',
                      status: 'Pending',
                      icon: Icons.arrow_upward,
                      iconColor: Color(0xFF8B4513),
                    ),
                    OverviewCard(
                      title: 'Receivables',
                      titleHindi: 'प्राप्य राशि',
                      value: '₹${(_stats?.receivables ?? 0.0).toStringAsFixed(0)}',
                      status: 'Pending',
                      icon: Icons.arrow_downward,
                      iconColor: Colors.green,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Quick Actions Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  children: [
                    QuickActionButton(
                      title: 'Add Labour Work',
                      titleHindi: 'श्रमिक कार्य जोड़े',
                      icon: Icons.add,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkTypeSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionButton(
                      title: 'Add Party',
                      titleHindi: 'पार्टी जोड़े',
                      icon: Icons.person_add,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddPartyScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionButton(
                      title: 'Add Transaction',
                      titleHindi: 'लेन-देन जोड़े',
                      icon: Icons.swap_horiz,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionTypeSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionButton(
                      title: 'Reports',
                      titleHindi: 'रिपोर्ट',
                      icon: Icons.assessment,
                      onTap: () {
                        if (widget.onNavigateToReports != null) {
                          widget.onNavigateToReports!();
                        } else {
                          _showComingSoonDialog('Reports');
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
