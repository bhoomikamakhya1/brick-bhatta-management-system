import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/report_service.dart';
import '../utils/csv_export_util.dart';
import '../utils/pdf_export_util.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  String _fromDate = 'dd-mm-yyyy';
  String _toDate = 'dd-mm-yyyy';
  List<TransactionItem> _filteredTransactions = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  void _loadFinancialData() {
    setState(() {
      _isLoading = true;
    });

    // Parse dates if set
    DateTime? startDate;
    DateTime? endDate;
    
    if (_fromDate != 'dd-mm-yyyy') {
      final parts = _fromDate.split('-');
      startDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }
    
    if (_toDate != 'dd-mm-yyyy') {
      final parts = _toDate.split('-');
      endDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }

    // Get filtered transactions
    _filteredTransactions = ReportService.getTransactionsInDateRange(startDate, endDate);
    _summary = ReportService.getFinancialSummary(_filteredTransactions);

    setState(() {
      _isLoading = false;
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
            const Icon(Icons.account_balance_wallet, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Financial Report',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'वित्तीय रिपोर्ट',
                  style: TextStyle(
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
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              _showExportOptions();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filters Card
                  _buildFiltersCard(),
                  const SizedBox(height: 16),

                  // Key Metrics Cards
                  _buildKeyMetricsCards(),
                  const SizedBox(height: 16),

                  // Transactions Table
                  _buildTransactionsTable(),
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
    );
  }

  Widget _buildFiltersCard() {
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
            const Text(
              'Filters / फिल्टर',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            // Date Range
            const Text(
              'Date Range / दिनांक सीमा',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('From', _fromDate, (value) {
                    setState(() {
                      _fromDate = value;
                    });
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField('To', _toDate, (value) {
                    setState(() {
                      _toDate = value;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _loadFinancialData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filters applied successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters / फिल्टर लगाएं',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, String value, Function(String) onChanged) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: value,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
              onPressed: () {
                _selectDate(label);
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                onChanged('dd-mm-yyyy');
              },
            ),
          ],
        ),
      ),
      onTap: () {
        _selectDate(label);
      },
    );
  }

  Widget _buildKeyMetricsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Income',
                '₹${(_summary['totalIncome'] ?? 0.0).toStringAsFixed(0)}',
                'Income / आय',
                const Color(0xFF4CAF50),
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Total Expense',
                '₹${(_summary['totalExpense'] ?? 0.0).toStringAsFixed(0)}',
                'Expense / व्यय',
                const Color(0xFFF44336),
                Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          'Net Profit',
          '₹${(_summary['netProfit'] ?? 0.0).toStringAsFixed(0)}',
          'Profit / लाभ',
          const Color(0xFF2196F3),
          Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTable() {
    if (_filteredTransactions.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No transactions found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
            const Text(
              'Transaction Details / लेन-देन विवरण',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Party', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _filteredTransactions.map((txn) {
                  return DataRow(
                    cells: [
                      DataCell(Text(txn.date)),
                      DataCell(Text(txn.englishName)),
                      DataCell(Text(txn.category)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: txn.type == TransactionType.credit
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            txn.type == TransactionType.credit ? 'Credit' : 'Debit',
                            style: TextStyle(
                              color: txn.type == TransactionType.credit
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text('₹${txn.amount?.toStringAsFixed(2) ?? '0.00'}')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(String label) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        final formattedDate = '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}';
        setState(() {
          if (label == 'From') {
            _fromDate = formattedDate;
          } else {
            _toDate = formattedDate;
          }
        });
      }
    });
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.green),
              title: const Text('Export as CSV'),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                // Capture context before async operation
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await CsvExportUtil.exportFinancialReport(_filteredTransactions);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('CSV exported successfully! Check Documents folder.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error exporting CSV: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                // Capture context before async operation
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await PdfExportUtil.exportFinancialReport(_filteredTransactions);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('PDF exported successfully! Check Documents folder.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error exporting PDF: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
