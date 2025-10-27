import 'package:flutter/material.dart';
import 'sales_report_screen.dart';
import 'financial_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.assessment, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'रिपोर्ट्स',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Stats Cards
            _buildQuickStatsCards(),
            const SizedBox(height: 24),

            // Report Types
            _buildReportTypes(),
            const SizedBox(height: 24),

            // Recent Reports
            _buildRecentReports(),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Overview / त्वरित अवलोकन',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sales',
                '₹2,45,000',
                '+10%',
                const Color(0xFF4CAF50),
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Expenses',
                '₹1,85,000',
                '-5%',
                const Color(0xFFF44336),
                Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Net Profit',
                '₹60,000',
                '+15%',
                const Color(0xFF4CAF50),
                Icons.emoji_events,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Projects',
                '12',
                '3 new',
                const Color(0xFF2196F3),
                Icons.work,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Types / रिपोर्ट प्रकार',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        _buildReportCard(
          'Sales Report / बिक्री रिपोर्ट',
          'View detailed sales data and trends',
          Icons.trending_up,
          const Color(0xFF4CAF50),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalesReportScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          'Financial Report / वित्तीय रिपोर्ट',
          'Complete financial overview and analysis',
          Icons.account_balance_wallet,
          const Color(0xFF2196F3),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FinancialReportScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          'Labour Report / मजदूरी रिपोर्ट',
          'Track labour work and payments',
          Icons.people,
          const Color(0xFFFF9800),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Labour Report coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          'Commission Report / कमीशन रिपोर्ट',
          'Monitor commission payments and calculations',
          Icons.percent,
          const Color(0xFF9C27B0),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Commission Report coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF666666),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reports / हाल की रिपोर्ट्स',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildRecentReportItem(
                'Sales Report - January 2024',
                'Generated 2 hours ago',
                Icons.trending_up,
                const Color(0xFF4CAF50),
              ),
              const Divider(height: 1),
              _buildRecentReportItem(
                'Financial Report - Q4 2023',
                'Generated 1 day ago',
                Icons.account_balance_wallet,
                const Color(0xFF2196F3),
              ),
              const Divider(height: 1),
              _buildRecentReportItem(
                'Labour Report - December 2023',
                'Generated 3 days ago',
                Icons.people,
                const Color(0xFFFF9800),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReportItem(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF666666),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download started')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share options')),
              );
            },
          ),
        ],
      ),
    );
  }
}
