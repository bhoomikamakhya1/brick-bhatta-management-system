import 'package:flutter/material.dart';
import '../constants/string_constants.dart';
import '../models/labour_work_model.dart';
import '../services/work_data_service.dart';
import 'work_type_selection_screen.dart';

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  List<LabourWork> _workEntries = [];

  @override
  void initState() {
    super.initState();
    _loadWorkEntries();
  }

  void _loadWorkEntries() {
    // Load work entries from the work data service
    setState(() {
      _workEntries = WorkDataService.getAllWorkEntries();
    });
  }

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
            const Icon(Icons.work, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringConstants.workEntries,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  StringConstants.workEntriesHindi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: _workEntries.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Summary Card
                _buildSummaryCard(),
                
                // Work Entries List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _workEntries.length,
                    itemBuilder: (context, index) {
                      final work = _workEntries[index];
                      return _buildWorkCard(work);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_work_fab",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkTypeSelectionScreen(),
            ),
          );
          
          // Refresh the list when returning from adding work
          if (result != null) {
            _loadWorkEntries();
          }
        },
        backgroundColor: const Color(0xFF8B4513),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Work Entries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'कुछ भी कार्य प्रविष्टि नहीं',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkTypeSelectionScreen(),
                ),
              );
              
              if (result != null) {
                _loadWorkEntries();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Work Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalEntries = _workEntries.length;
    final totalAmount = _workEntries.fold(0.0, (sum, work) => sum + work.totalAmount);
    final todayEntries = _workEntries.where((work) => 
      work.date.day == DateTime.now().day &&
      work.date.month == DateTime.now().month &&
      work.date.year == DateTime.now().year
    ).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total Entries',
              'कुल प्रविष्टियां',
              totalEntries.toString(),
              Icons.list_alt,
              const Color(0xFF2196F3),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildSummaryItem(
              'Today\'s Entries',
              'आज की प्रविष्टियां',
              todayEntries.toString(),
              Icons.today,
              const Color(0xFF4CAF50),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildSummaryItem(
              'Total Amount',
              'कुल राशि',
              '₹${totalAmount.toStringAsFixed(0)}',
              Icons.currency_rupee,
              const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String titleHindi, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          titleHindi,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkCard(LabourWork work) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showWorkDetails(work);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(work.labourCategory).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      work.labourCategory,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(work.labourCategory),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${work.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      work.labourName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.scale,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${work.quantity.toInt()} units',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${work.rate.toInt()}/unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(work.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'pathai':
        return const Color(0xFF2196F3);
      case 'bharai':
        return const Color(0xFF4CAF50);
      case 'nikasi':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showWorkDetails(LabourWork work) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(work.labourName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Category', work.labourCategory),
            _buildDetailRow('Quantity', '${work.quantity.toInt()} units'),
            if (work.percentage != null)
              _buildDetailRow('Percentage', '${work.percentage!.toStringAsFixed(1)}%'),
            _buildDetailRow('Rate', '₹${work.rate.toInt()}/unit'),
            _buildDetailRow('Total Amount', '₹${work.totalAmount.toStringAsFixed(0)}'),
            _buildDetailRow('Date', _formatDate(work.date)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Work Entries'),
        content: const Text('Filter functionality will be implemented here.'),
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
