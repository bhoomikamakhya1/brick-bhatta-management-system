import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../widgets/user_header.dart';
import '../widgets/overview_card.dart';
import '../widgets/quick_action_button.dart';
import 'add_labour_work_screen.dart';
import 'commission_entry_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardStats stats = DashboardStats.sample();

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
                      value: stats.labourEntries.toString(),
                      status: 'Today',
                      icon: Icons.groups,
                      iconColor: Color(0xFF8B4513),
                    ),
                    OverviewCard(
                      title: 'Sales Today',
                      titleHindi: 'आज की बिक्री',
                      value: '₹${stats.salesToday.toStringAsFixed(0)}',
                      status: 'Today',
                      icon: Icons.show_chart,
                      iconColor: Color(0xFF8B4513),
                    ),
                    OverviewCard(
                      title: 'Payables',
                      titleHindi: 'देय राशि',
                      value: '₹${stats.payables.toStringAsFixed(0)}',
                      status: 'Pending',
                      icon: Icons.arrow_upward,
                      iconColor: Color(0xFF8B4513),
                    ),
                    OverviewCard(
                      title: 'Receivables',
                      titleHindi: 'प्राप्य राशि',
                      value: '₹${stats.receivables.toStringAsFixed(0)}',
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
                            builder: (context) => const AddLabourWorkScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionButton(
                      title: 'Add Sale',
                      titleHindi: 'बिक्री जोड़े',
                      icon: Icons.shopping_cart,
                      onTap: () {
                        _showComingSoonDialog('Add Sale');
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
                            builder: (context) => const CommissionEntryScreen(),
                          ),
                        );
                      },
                    ),
                    QuickActionButton(
                      title: 'Reports',
                      titleHindi: 'रिपोर्ट',
                      icon: Icons.assessment,
                      onTap: () {
                        _showComingSoonDialog('Reports');
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
