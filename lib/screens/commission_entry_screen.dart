import 'package:flutter/material.dart';
import '../models/commission_model.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/recent_entry_item.dart';
import '../widgets/bottom_navigation.dart';

class CommissionEntryScreen extends StatefulWidget {
  const CommissionEntryScreen({super.key});

  @override
  State<CommissionEntryScreen> createState() => _CommissionEntryScreenState();
}

class _CommissionEntryScreenState extends State<CommissionEntryScreen> {
  String? selectedThekedaar;
  String? selectedType;
  DateTime? fromDate;
  DateTime? toDate;
  double baseAmount = 25000.0;
  double commissionPercentage = 5.0;
  double commissionAmount = 1250.0;

  final List<String> thekedaars = [
    'राम कुमार',
    'मोहन लाल',
    'सुरेश गुप्ता',
    'अमित सिंह',
    'राजेश कुमार',
  ];

  final List<String> types = [
    'Pathai',
    'Bharai',
  ];

  @override
  Widget build(BuildContext context) {
    final recentEntries = CommissionData.getRecentEntries();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Commission Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              'कमीशन एंट्री',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF333333)),
            onPressed: () {
              // TODO: Show menu options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Commission Entry Form Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thekedaar Name Dropdown
                  CustomDropdown(
                    label: 'Thekedaar Name',
                    labelHindi: 'ठेकेदार का नाम',
                    hint: 'Select Thekedaar',
                    hintHindi: 'ठेकेदार चुनें',
                    value: selectedThekedaar,
                    items: thekedaars,
                    onChanged: (value) {
                      setState(() {
                        selectedThekedaar = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Thekedaar Type Dropdown
                  CustomDropdown(
                    label: 'Thekedaar Type',
                    labelHindi: 'ठेकेदार का प्रकार',
                    hint: 'Select Type',
                    hintHindi: 'प्रकार चुनें',
                    value: selectedType,
                    items: types,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Date Range Picker
                  DateRangePicker(
                    label: 'Date Range',
                    labelHindi: 'दिनांक सीमा',
                    fromDate: fromDate,
                    toDate: toDate,
                    onFromDateTap: () => _selectFromDate(context),
                    onToDateTap: () => _selectToDate(context),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Base Amount Field
                  CustomTextField(
                    label: 'Base Amount',
                    labelHindi: 'आधार राशि',
                    value: baseAmount.toStringAsFixed(0),
                    suffix: const Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    readOnly: true,
                  ),
                  
                  const SizedBox(height: 4),
                  Text(
                    '(Auto-calculated / स्वतः गणना)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Commission Percentage Field
                  CustomTextField(
                    label: 'Commission %',
                    labelHindi: 'कमीशन प्रतिशत',
                    value: commissionPercentage.toStringAsFixed(0),
                    suffix: const Text(
                      '%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final percentage = double.tryParse(value) ?? 0.0;
                      setState(() {
                        commissionPercentage = percentage;
                        commissionAmount = (baseAmount * percentage) / 100;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Commission Amount Field
                  CustomTextField(
                    label: 'Commission Amount',
                    labelHindi: 'कमीशन राशि',
                    value: commissionAmount.toStringAsFixed(0),
                    suffix: const Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    readOnly: true,
                  ),
                  
                  const SizedBox(height: 4),
                  Text(
                    '(Auto-calculated / स्वतः गणना)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveCommission();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save Commission',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'कमीशन सेव करें',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Entries Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'हाल की एंट्री',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Recent Entries List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentEntries.length,
              itemBuilder: (context, index) {
                final entry = recentEntries[index];
                return RecentEntryItem(
                  entry: entry,
                  onTap: () {
                    // TODO: Navigate to entry details
                    _showEntryDetails(entry);
                  },
                );
              },
            ),
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
    }
  }

  void _saveCommission() {
    if (selectedThekedaar == null || selectedType == null || fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Save commission entry
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commission saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEntryDetails(CommissionEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${entry.thekedaarName} - ${entry.thekedaarType}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${entry.fromDate.day}-${entry.fromDate.month}-${entry.fromDate.year}'),
            Text('To: ${entry.toDate.day}-${entry.toDate.month}-${entry.toDate.year}'),
            Text('Base Amount: ₹${entry.baseAmount.toInt()}'),
            Text('Commission %: ${entry.commissionPercentage.toInt()}%'),
            Text('Commission Amount: ₹${entry.commissionAmount.toInt()}'),
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
