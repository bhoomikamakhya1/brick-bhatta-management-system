import 'package:flutter/material.dart';
import '../constants/string_constants.dart';
import '../models/labour_work_model.dart';
import '../services/work_data_service.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/form_text_field.dart';
import '../widgets/category_chip.dart';

class AddLabourWorkScreen extends StatefulWidget {
  final String? workType;
  
  const AddLabourWorkScreen({super.key, this.workType});

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

  // Nikasi-specific fields
  String? selectedRound;
  String? selectedBrickType;
  String? selectedCalculationType;
  double piecesPerRound = 250.0;
  double totalQuantity = 0.0;
  double amount = 0.0;
  final TextEditingController _notesController = TextEditingController();

  final List<String> labourNames = LabourData.getLabourNames();
  final List<LabourCategory> categories = LabourData.getLabourCategories();
  
  final List<String> rounds = [
    '1 Round / 1 चक्कर',
    '2 Round / 2 चक्कर',
    '3 Round / 3 चक्कर',
    '4 Round / 4 चक्कर',
    '5 Round / 5 चक्कर',
    '6 Round / 6 चक्कर',
    '7 Round / 7 चक्कर',
    '8 Round / 8 चक्कर',
  ];

  final List<String> brickTypes = [
    'Red Brick / लाल ईंट',
    'Fly Ash Brick / फ्लाई ऐश ईंट',
    'Concrete Block / कंक्रीट ब्लॉक',
    'Hollow Brick / खोखली ईंट',
  ];

  final List<String> calculationTypes = [
    'Pai / पाई',
    'Row / पंक्ति',
    'No of Bricks / ईंटों की संख्या',
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    if (widget.workType == 'Nikasi') {
      selectedRound = rounds[0]; // Default to first round
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (widget.workType == 'Nikasi') {
      _calculateNikasiAmounts();
    } else {
      setState(() {
        totalAmount = quantity * rate;
        if (percentage != null && percentage! > 0) {
          totalAmount = totalAmount * (percentage! / 100);
        }
      });
    }
  }

  void _calculateNikasiAmounts() {
    if (selectedRound != null) {
      final roundNumber = int.tryParse(selectedRound!.split(' ')[0]) ?? 1;
      setState(() {
        totalQuantity = piecesPerRound * roundNumber;
        amount = totalQuantity * 2.0; // Assuming ₹2 per piece
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.workType != null 
            ? 'Add ${widget.workType} Work'
            : StringConstants.getBilingual(StringConstants.addLabourWork, StringConstants.addLabourWorkHindi),
          style: const TextStyle(
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
              child: widget.workType == 'Nikasi' 
                ? _buildNikasiForm()
                : _buildPathaiBharaiForm(),
            ),
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildNikasiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Labour Name Dropdown
        CustomDropdown(
          label: 'Labour Name',
          labelHindi: 'मजदूर का नाम',
          hint: 'Select Labour',
          hintHindi: 'मजदूर चुनें',
          value: selectedLabour,
          items: labourNames,
          onChanged: (value) {
            setState(() {
              selectedLabour = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Calculation Type Dropdown
        CustomDropdown(
          label: 'Type of Calculations',
          labelHindi: 'गणना का प्रकार',
          hint: 'Select Type',
          hintHindi: 'प्रकार चुनें',
          value: selectedCalculationType,
          items: calculationTypes,
          onChanged: (value) {
            setState(() {
              selectedCalculationType = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Brick Type Dropdown
        CustomDropdown(
          label: 'Brick Type',
          labelHindi: 'ईंट का प्रकार',
          hint: 'Select Brick Type',
          hintHindi: 'ईंट का प्रकार चुनें',
          value: selectedBrickType,
          items: brickTypes,
          onChanged: (value) {
            setState(() {
              selectedBrickType = value;
            });
          },
        ),
        
        const SizedBox(height: 20),
        
        // Auto Calculated Section
        const Text(
          'Auto Calculated / स्वचालित गणना',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        
        // Pieces per Round
        FormTextField(
          label: 'Pieces per Round',
          labelHindi: 'प्रति चक्कर टुकड़े',
          value: '${piecesPerRound.toInt()} pieces / टुकड़े',
          readOnly: true,
        ),
        
        const SizedBox(height: 16),
        
        // Total Quantity
        FormTextField(
          label: 'Total Quantity',
          labelHindi: 'कुल मात्रा',
          value: '${totalQuantity.toInt()} pieces / टुकड़े',
          readOnly: true,
        ),
        
        const SizedBox(height: 16),
        
        // Amount
        FormTextField(
          label: 'Amount',
          labelHindi: 'राशि',
          value: '₹ ${amount.toStringAsFixed(0)}',
          readOnly: true,
        ),
        
        const SizedBox(height: 20),
        
        // Notes Field
        FormTextField(
          label: 'Notes (Optional)',
          labelHindi: 'टिप्पणी (वैकल्पिक)',
          hint: 'Add any notes',
          hintHindi: 'कोई टिप्पणी जोड़ें',
          controller: _notesController,
          maxLines: 3,
        ),
        
        const SizedBox(height: 24),
        
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
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
            icon: const Icon(Icons.save, size: 20),
            label: const Text(
              'Save Entry / एंट्री सेव करें',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathaiBharaiForm() {
    return Column(
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
    );
  }

  void _saveLabourWork() {
    if (widget.workType == 'Nikasi') {
      if (selectedLabour == null || selectedBrickType == null || selectedCalculationType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (selectedLabour == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      // Create work entry based on work type
      final workEntry = _createWorkEntry();
      
      // Save to work data service
      WorkDataService.addWorkEntry(workEntry);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.workType ?? 'Labour'} work saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _clearForm();
      
      // Navigate back to work list
      Navigator.pop(context, workEntry);
      
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving work: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  LabourWork _createWorkEntry() {
    final workType = widget.workType ?? 'General';
    final workQuantity = widget.workType == 'Nikasi' ? totalQuantity : quantity;
    final workAmount = widget.workType == 'Nikasi' ? amount : totalAmount;
    final workRate = widget.workType == 'Nikasi' ? 2.0 : rate; // ₹2 per piece for Nikasi

    return LabourWork(
      id: WorkDataService.generateId(),
      labourName: selectedLabour!,
      labourCategory: workType,
      quantity: workQuantity,
      percentage: percentage,
      rate: workRate,
      totalAmount: workAmount,
      date: DateTime.now(),
    );
  }

  void _clearForm() {
    setState(() {
      selectedLabour = null;
      selectedCategory = null;
      selectedBrickType = null;
      selectedCalculationType = null;
      quantity = 0.0;
      percentage = null;
      rate = LabourData.getDefaultRate();
      totalAmount = 0.0;
      totalQuantity = 0.0;
      amount = 0.0;
      _notesController.clear();
    });
  }
}
