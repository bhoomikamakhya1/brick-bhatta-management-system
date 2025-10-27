import 'package:flutter/material.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String _fromDate = 'dd-mm-yyyy';
  String _toDate = 'dd-mm-yyyy';
  String _selectedClient = 'All Clients / सभी ग्राहक';

  final List<String> _clients = [
    'All Clients / सभी ग्राहक',
    'Ram Construction / राम कंस्ट्रक्शन',
    'Sharma Builders / शर्मा बिल्डर्स',
    'Gupta Transport / गुप्ता ट्रांसपोर्ट',
    'Patel Builders / पटेल बिल्डर्स',
  ];

  final List<Map<String, dynamic>> _salesData = [
    {
      'date': '15/01/24',
      'client': 'Ram Construction',
      'qty': '500',
      'rate': '₹10',
      'amount': '₹5,000',
    },
    {
      'date': '16/01/24',
      'client': 'Sharma Builders',
      'qty': '750',
      'rate': '₹8',
      'amount': '₹6,000',
    },
    {
      'date': '17/01/24',
      'client': 'Gupta Transport',
      'qty': '300',
      'rate': '₹12',
      'amount': '₹3,600',
    },
    {
      'date': '18/01/24',
      'client': 'Patel Builders',
      'qty': '600',
      'rate': '₹9',
      'amount': '₹5,400',
    },
  ];

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
                  'Sales Report',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'बिक्री रिपोर्ट',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters Card
            _buildFiltersCard(),
            const SizedBox(height: 16),

            // Summary Cards
            _buildSummaryCards(),
            const SizedBox(height: 16),

            // Sales Details Table
            _buildSalesDetailsTable(),
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
            const SizedBox(height: 16),

            // Client Filter
            const Text(
              'Client / ग्राहक',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedClient,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _clients.map((String client) {
                return DropdownMenuItem<String>(
                  value: client,
                  child: Text(client),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClient = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _applyFilters();
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Sales / कुल बिक्री',
            '₹2,45,000',
            const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Qty / कुल मात्रा',
            '1,250',
            const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesDetailsTable() {
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
              'Sales Details / बिक्री विवरण',
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
                  DataColumn(label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _salesData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(data['date'])),
                      DataCell(Text(data['client'])),
                      DataCell(Text(data['qty'])),
                      DataCell(Text(data['rate'])),
                      DataCell(Text(data['amount'])),
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

  void _applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export started')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export started')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
