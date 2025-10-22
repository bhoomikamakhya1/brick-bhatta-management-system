import 'package:flutter/material.dart';
import '../models/labour_work_model.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/form_text_field.dart';
import '../widgets/category_chip.dart';
import '../widgets/bottom_navigation.dart';

class AddLabourWorkScreen extends StatefulWidget {
  const AddLabourWorkScreen({super.key});

  @override
  State<AddLabourWorkScreen> createState() => _AddLabourWorkScreenState();
}

class _AddLabourWorkScreenState extends State<AddLabourWorkScreen> {
  String? selectedLabour;
  String? selectedCategory;
  double quantity = 0.0;
  double? percentage;
  double rate = LabourData.getDefaultRate();
  double totalAmount = 0.0;

  final List<String> labourNames = LabourData.getLabourNames();
  final List<LabourCategory> categories = LabourData.getLabourCategories();

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() {
    setState(() {
      totalAmount = quantity * rate;
      if (percentage != null && percentage! > 0) {
        totalAmount = totalAmount * (percentage! / 100);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add Labour Work',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B4513), // Dark orange/brown
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
            
            // Form Card
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
                  // Labour Name Dropdown
                  CustomDropdown(
                    label: 'Labour Name',
                    labelHindi: 'श्रमिक का नाम',
                    hint: 'Select Labour',
                    hintHindi: 'श्रमिक चुनें',
                    value: selectedLabour,
                    items: labourNames,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category Chips
                  const Text(
                    'Labour Name *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLabour,
                        isExpanded: true,
                        hint: Text(
                          'Select Labour',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        items: labourNames.map((String name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLabour = value;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category Chips
                  Wrap(
                    children: categories.map((category) {
                      return CategoryChip(
                        label: category.name,
                        backgroundColor: category.color,
                        isSelected: selectedCategory == category.name,
                        onTap: () {
                          setState(() {
                            selectedCategory = category.name;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quantity Field
                  FormTextField(
                    label: 'Quantity *',
                    hint: 'Enter quantity',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 0.0;
                      setState(() {
                        quantity = qty;
                      });
                      _calculateTotal();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Percentage Field
                  FormTextField(
                    label: 'Percentage (Optional)',
                    hint: 'Enter percentage',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final pct = double.tryParse(value);
                      setState(() {
                        percentage = pct;
                      });
                      _calculateTotal();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Rate Field
                  FormTextField(
                    label: 'Rate',
                    value: rate.toStringAsFixed(2),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final r = double.tryParse(value) ?? LabourData.getDefaultRate();
                      setState(() {
                        rate = r;
                      });
                      _calculateTotal();
                    },
                  ),
                  
                  const SizedBox(height: 4),
                  Text(
                    'Default from Rate Master',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Total Amount Field
                  FormTextField(
                    label: 'Total Amount',
                    value: '₹ ${totalAmount.toStringAsFixed(2)}',
                    readOnly: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveLabourWork();
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
                        'Save Entry',
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
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  void _saveLabourWork() {
    if (selectedLabour == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Save labour work entry
    final labourWork = LabourWork(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      labourName: selectedLabour!,
      labourCategory: selectedCategory ?? '',
      quantity: quantity,
      percentage: percentage,
      rate: rate,
      totalAmount: totalAmount,
      date: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Labour work saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    setState(() {
      selectedLabour = null;
      selectedCategory = null;
      quantity = 0.0;
      percentage = null;
      rate = LabourData.getDefaultRate();
      totalAmount = 0.0;
    });
  }
}
