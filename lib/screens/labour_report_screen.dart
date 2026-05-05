import 'package:flutter/material.dart';
import '../models/labour_work_model.dart';
import '../services/work_data_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';

class LabourReportScreen extends StatefulWidget {
  const LabourReportScreen({super.key});

  @override
  State<LabourReportScreen> createState() => _LabourReportScreenState();
}

class _LabourReportScreenState extends State<LabourReportScreen> {
  String _fromDate = 'dd-mm-yyyy';
  String _toDate = 'dd-mm-yyyy';
  List<LabourWork> _filteredLabourWorks = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLabourData();
  }

  void _loadLabourData() {
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

    // Get all labour works from WorkDataService
    final allWorks = WorkDataService.getAllWorkEntries();
    
    // Filter by date range
    _filteredLabourWorks = allWorks.where((work) {
      if (startDate != null && work.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && work.date.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();

    // Calculate summary
    double totalAmount = 0.0;
    double totalQuantity = 0.0;
    
    for (var work in _filteredLabourWorks) {
      totalAmount += work.totalAmount;
      totalQuantity += work.quantity;
    }

    _summary = {
      'totalWorks': _filteredLabourWorks.length,
      'totalAmount': totalAmount,
      'totalQuantity': totalQuantity,
      'averageAmount': _filteredLabourWorks.isEmpty ? 0.0 : totalAmount / _filteredLabourWorks.length,
    };

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
            const Icon(Icons.people, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Labour Report',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'मजदूरी रिपोर्ट',
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

                  // Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 16),

                  // Labour Details Table
                  _buildLabourDetailsTable(),
                  const SizedBox(height: 100),
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
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _loadLabourData();
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

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Amount / कुल राशि',
                '₹${(_summary['totalAmount'] ?? 0.0).toStringAsFixed(0)}',
                const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Works / कुल काम',
                '${_summary['totalWorks'] ?? 0}',
                const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Total Quantity / कुल मात्रा',
          '${(_summary['totalQuantity'] ?? 0.0).toStringAsFixed(0)}',
          const Color(0xFF4CAF50),
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

  Widget _buildLabourDetailsTable() {
    if (_filteredLabourWorks.isEmpty) {
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
                  'No labour work data found',
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
              'Labour Work Details / मजदूरी विवरण',
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
                  DataColumn(label: Text('Labour', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _filteredLabourWorks.map((work) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${work.date.day}-${work.date.month}-${work.date.year}')),
                      DataCell(Text(work.labourName)),
                      DataCell(Text(work.labourCategory)),
                      DataCell(Text(work.quantity.toStringAsFixed(0))),
                      DataCell(Text('₹${work.rate.toStringAsFixed(2)}')),
                      DataCell(Text('₹${work.totalAmount.toStringAsFixed(2)}')),
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
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await _exportLabourCSV();
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
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await _exportLabourPDF();
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

  Future<void> _exportLabourCSV() async {
    try {
      // Create CSV data
      List<List<dynamic>> rows = [
        ['Date', 'Labour Name', 'Category', 'Quantity', 'Rate', 'Amount'],
      ];

      for (var work in _filteredLabourWorks) {
        rows.add([
          '${work.date.day}-${work.date.month}-${work.date.year}',
          work.labourName,
          work.labourCategory,
          work.quantity.toStringAsFixed(0),
          'Rs.${work.rate.toStringAsFixed(2)}',
          'Rs.${work.totalAmount.toStringAsFixed(2)}',
        ]);
      }

      // Add summary
      rows.add([]);
      rows.add(['Summary']);
      rows.add(['Total Works', _summary['totalWorks'].toString()]);
      rows.add(['Total Amount', 'Rs.${(_summary['totalAmount'] ?? 0.0).toStringAsFixed(2)}']);
      rows.add(['Total Quantity', (_summary['totalQuantity'] ?? 0.0).toStringAsFixed(0)]);

      String csv = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/labour_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      // Try to share
      try {
        await Share.shareXFiles([XFile(path)], text: 'Labour Report');
      } catch (shareError) {
        print('⚠️ Share not available: $shareError');
        print('✅ File saved to: $path');
      }

      print('✅ CSV exported successfully: $path');
    } catch (e) {
      print('❌ Error exporting CSV: $e');
      rethrow;
    }
  }

  Future<void> _exportLabourPDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Labour Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Generated: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}'),
                pw.SizedBox(height: 20),
                
                // Summary
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text('Total Works: ${_summary['totalWorks'] ?? 0}'),
                      pw.Text('Total Amount: Rs.${(_summary['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                        style: const pw.TextStyle(color: PdfColors.green)),
                      pw.Text('Total Quantity: ${(_summary['totalQuantity'] ?? 0.0).toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Table
                pw.Text('Work Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Labour', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ..._filteredLabourWorks.map((work) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${work.date.day}-${work.date.month}-${work.date.year}')),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(work.labourName)),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(work.labourCategory)),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(work.quantity.toStringAsFixed(0))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Rs.${work.totalAmount.toStringAsFixed(2)}')),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/labour_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      // Try to share
      try {
        await Share.shareXFiles([XFile(path)], text: 'Labour Report PDF');
      } catch (shareError) {
        print('⚠️ Share not available: $shareError');
        print('✅ File saved to: $path');
      }

      print('✅ PDF exported successfully: $path');
    } catch (e) {
      print('❌ Error exporting PDF: $e');
      rethrow;
    }
  }
}
