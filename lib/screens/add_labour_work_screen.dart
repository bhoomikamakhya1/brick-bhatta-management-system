import 'package:flutter/material.dart';
import '../constants/string_constants.dart';
import '../models/labour_work_model.dart';
import '../services/work_data_service.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/form_text_field.dart';
import '../widgets/category_chip.dart';

// Model for Pathai Labour Entry in Bharai form
class PathaiLabourEntry {
  String? pathaiThekedar;
  String? pathaiLabourName;
  double quantity;
  final String id;

  PathaiLabourEntry({
    this.pathaiThekedar,
    this.pathaiLabourName,
    this.quantity = 0.0,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

// Model for Brick Entry in Nikasi form
class BrickEntry {
  String? brickType;
  double quantity;
  final String id;

  BrickEntry({
    this.brickType,
    this.quantity = 0.0,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class AddLabourWorkScreen extends StatefulWidget {
  final String? workType;
  
  const AddLabourWorkScreen({super.key, this.workType});

  @override
  State<AddLabourWorkScreen> createState() => _AddLabourWorkScreenState();
}

class _AddLabourWorkScreenState extends State<AddLabourWorkScreen> {
  String? selectedThekedar;
  String? selectedLabour;
  String? selectedCategory;
  double quantity = 0.0;
  double? percentage;
  double rate = LabourData.getDefaultRate();
  double totalAmount = 0.0;

  // Bharai-specific: Multiple Pathai labour entries
  List<PathaiLabourEntry> pathaiLabourEntries = [];

  // Nikasi-specific fields
  String? selectedRound;
  String? selectedBrickType;
  String? selectedCalculationType;
  double piecesPerRound = 250.0;
  double totalQuantity = 0.0;
  double amount = 0.0;
  // Nikasi-specific: Multiple brick entries
  List<BrickEntry> brickEntries = [];

  // Get thekedar names filtered by labour type matching the form type
  List<String> get filteredThekedarNames {
    final labourType = _getLabourTypeForForm();
    return LabourData.getThekedarNames(labourType: labourType);
  }
  
  // Get filtered labour names based on selected thekedar and form type
  List<String> get filteredLabourNames {
    final labourType = _getLabourTypeForForm();
    return LabourData.getLabourNamesByThekedar(selectedThekedar, labourType: labourType);
  }

  // Get filtered pathai labour names based on selected pathai thekedar
  // For Pathai entries in Bharai form, always use 'Pathai' as the labour type
  List<String> getPathaiLabourNames(String? pathaiThekedar) {
    return LabourData.getLabourNamesByThekedar(pathaiThekedar, labourType: 'Pathai');
  }
  
  // Get the labour type for the current form
  String? _getLabourTypeForForm() {
    if (widget.workType == 'Bharai') {
      return 'Bharai';
    } else if (widget.workType == 'Nikasi') {
      return 'Nikasi';
    } else {
      // Pathai form (when workType is null or 'Pathai')
      return 'Pathai';
    }
  }

  // Calculate total quantity from all pathai labour entries
  double get totalPathaiQuantity {
    return pathaiLabourEntries.fold(0.0, (sum, entry) => sum + entry.quantity);
  }
  
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
    'Awwal / अव्वल',
    'Doyam / दोयम',
    'Talsa / तलसा',
    'Chatka / चटका',
    'Kaccha Peela / कच्चा पीला',
    'Pakka Peela / पक्का पीला',
  ];
  
  // Calculate total quantity from all brick entries
  double get totalBrickQuantity {
    return brickEntries.fold(0.0, (sum, entry) => sum + entry.quantity);
  }

  final List<String> calculationTypes = [
    'Pai / पाई',
    'Row / पंक्ति',
    'No of Bricks / ईंटों की संख्या',
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _calculateTotal() {
    if (widget.workType == 'Nikasi') {
      _calculateNikasiAmounts();
    } else if (widget.workType == 'Bharai') {
      // For Bharai, use total pathai quantity and Bharai labour rate
      if (selectedLabour != null) {
        final bharaiLabourRate = LabourData.getRateForLabour(selectedLabour!);
        setState(() {
          quantity = totalPathaiQuantity;
          rate = bharaiLabourRate;
          totalAmount = totalPathaiQuantity * bharaiLabourRate; // Use Bharai labour rate
        });
      }
    } else {
      // Pathai form: Fetch rate for selected labour and calculate amount
      if (selectedLabour != null) {
        final labourRate = LabourData.getRateForLabour(selectedLabour!);
        setState(() {
          rate = labourRate;
          totalAmount = quantity * rate;
        });
      }
    }
  }

  // Add new pathai labour entry
  void _addPathaiLabourEntry() {
    setState(() {
      pathaiLabourEntries.add(PathaiLabourEntry());
    });
  }

  // Remove pathai labour entry
  void _removePathaiLabourEntry(String id) {
    setState(() {
      pathaiLabourEntries.removeWhere((entry) => entry.id == id);
    });
    _calculateTotal(); // Recalculate total amount using Bharai labour rate
  }

  void _calculateNikasiAmounts() {
    if (selectedLabour != null) {
      final labourRate = LabourData.getRateForLabour(selectedLabour!);
      setState(() {
        rate = labourRate;
        // Calculate total quantity from all brick entries
        totalQuantity = totalBrickQuantity;
        amount = totalQuantity * rate; // Calculate amount from fetched rate
      });
    }
  }
  
  // Add new brick entry
  void _addBrickEntry() {
    setState(() {
      brickEntries.add(BrickEntry());
    });
  }

  // Remove brick entry
  void _removeBrickEntry(String id) {
    setState(() {
      brickEntries.removeWhere((entry) => entry.id == id);
    });
    _calculateTotal(); // Recalculate total amount
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
        // Thekedar Dropdown
        CustomDropdown(
          label: 'Thekedar',
          labelHindi: 'ठेकेदार',
          hint: 'Select Thekedar',
          hintHindi: 'ठेकेदार चुनें',
          value: selectedThekedar,
          items: filteredThekedarNames,
          onChanged: (value) {
            setState(() {
              selectedThekedar = value;
              selectedLabour = null; // Reset labour when thekedar changes
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Labour Name Dropdown
        CustomDropdown(
          label: 'Labour Name',
          labelHindi: 'मजदूर का नाम',
          hint: 'Select Labour',
          hintHindi: 'मजदूर चुनें',
          value: selectedLabour,
          items: filteredLabourNames,
          onChanged: (value) {
            setState(() {
              selectedLabour = value;
              // Fetch rate for selected labour from ledger entries
              if (value != null) {
                rate = LabourData.getRateForLabour(value);
              }
            });
            _calculateTotal();
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
        
        // Show brick entries section only if "No of Bricks" is selected
        if (selectedCalculationType == 'No of Bricks / ईंटों की संख्या') ...[
          const SizedBox(height: 20),
          
          // Brick Entries Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Brick Entries / ईंट प्रविष्टियां',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF8B4513)),
                onPressed: _addBrickEntry,
                tooltip: 'Add Brick Entry',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // List of Brick Entries
          ...brickEntries.map((entry) => _buildBrickEntry(entry)),
          
          const SizedBox(height: 16),
          
          // Total Quantity (Auto-calculated)
          FormTextField(
            label: 'Total Quantity (Auto-calculated)',
            labelHindi: 'कुल मात्रा (स्वचालित)',
            value: totalBrickQuantity.toStringAsFixed(2),
            readOnly: true,
          ),
          
          const SizedBox(height: 16),
          
          // Total Amount
          FormTextField(
            label: 'Total Amount',
            labelHindi: 'कुल राशि',
            value: '₹ ${amount.toStringAsFixed(2)}',
            readOnly: true,
          ),
        ],
        
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
        // Thekedar Dropdown
        CustomDropdown(
          label: 'Thekedar',
          labelHindi: 'ठेकेदार',
          hint: 'Select Thekedar',
          hintHindi: 'ठेकेदार चुनें',
          value: selectedThekedar,
          items: filteredThekedarNames,
          onChanged: (value) {
            setState(() {
              selectedThekedar = value;
              selectedLabour = null; // Reset labour when thekedar changes
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Labour Name Dropdown (Bharai Labour)
        if (widget.workType=='Bharai')
        CustomDropdown(
          label: 'Bharai Labour Name',
          labelHindi: 'भराई श्रमिक का नाम',
          hint: 'Select Bharai Labour',
          hintHindi: 'भराई श्रमिक चुनें',
          value: selectedLabour,
          items: filteredLabourNames,
          onChanged: (value) {
            setState(() {
              selectedLabour = value;
              // Fetch rate for selected Bharai labour from ledger entries
              if (value != null) {
                rate = LabourData.getRateForLabour(value);
              }
            });
            _calculateTotal();
          },
        )
        else
          CustomDropdown(
            label: 'Pathai Labour Name',
            labelHindi: 'पठाई श्रमिक का नाम',
            hint: 'Select Pathai Labour',
            hintHindi: 'पठाई श्रमिक चुनें',
            value: selectedLabour,
            items: filteredLabourNames,
            onChanged: (value) {
              setState(() {
                selectedLabour = value;
                // Fetch rate for selected Pathai labour from ledger entries
                if (value != null) {
                  rate = LabourData.getRateForLabour(value);
                }
              });
              _calculateTotal();
            },
          ),
        
        const SizedBox(height: 16),
        
        // Category Chips
        // Wrap(
        //   children: categories.map((category) {
        //     return CategoryChip(
        //       label: category.name,
        //       backgroundColor: category.color,
        //       isSelected: selectedCategory == category.name,
        //       onTap: () {
        //         setState(() {
        //           selectedCategory = category.name;
        //         });
        //       },
        //     );
        //   }).toList(),
        // ),
        
        const SizedBox(height: 20),
        
        // For Bharai: Show Pathai Labour section
        if (widget.workType == 'Bharai') ...[
          // Pathai Labour Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pathai Labour / पठाई श्रमिक',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF8B4513)),
                onPressed: _addPathaiLabourEntry,
                tooltip: 'Add Pathai Labour',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // List of Pathai Labour Entries
          ...pathaiLabourEntries.map((entry) => _buildPathaiLabourEntry(entry)),
          
          const SizedBox(height: 16),
          
          // Total Quantity (Auto-calculated)
          FormTextField(
            label: 'Total Quantity (Auto-calculated)',
            labelHindi: 'कुल मात्रा (स्वचालित)',
            value: totalPathaiQuantity.toStringAsFixed(2),
            readOnly: true,
          ),
        ] else ...[
          // For Pathai: Show regular Quantity Field
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
        ],
        
        const SizedBox(height: 20),
        
        // Rate Field - Commented out (Rate will be fetched from DB for each labour in ledger entry)
        // FormTextField(
        //   label: 'Rate',
        //   value: rate.toStringAsFixed(2),
        //   keyboardType: TextInputType.number,
        //   onChanged: (value) {
        //     final r = double.tryParse(value) ?? LabourData.getDefaultRate();
        //     setState(() {
        //       rate = r;
        //     });
        //     _calculateTotal();
        //   },
        // ),
        // 
        // const SizedBox(height: 4),
        // Text(
        //   'Default from Rate Master',
        //   style: TextStyle(
        //     fontSize: 10,
        //     color: Colors.grey[500],
        //   ),
        // ),
        
        // const SizedBox(height: 20),
        
        // Total Amount Field (Will be calculated from DB rates in ledger entry)
        FormTextField(
          label: 'Total Amount',
          labelHindi: 'कुल राशि',
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
      if (selectedLabour == null || selectedCalculationType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Validate brick entries if "No of Bricks" is selected
      if (selectedCalculationType == 'No of Bricks / ईंटों की संख्या') {
        if (brickEntries.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one brick entry'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        // Validate all brick entries
        for (var entry in brickEntries) {
          if (entry.brickType == null || entry.quantity <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all brick entries completely'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        if (totalBrickQuantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Total quantity must be greater than 0'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    } else if (widget.workType == 'Bharai') {
      // Validate Bharai form
      if (selectedLabour == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Bharai labour'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (pathaiLabourEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one Pathai labour entry'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Validate all pathai entries
      for (var entry in pathaiLabourEntries) {
        if (entry.pathaiThekedar == null || entry.pathaiLabourName == null || entry.quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all Pathai labour entries completely'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (totalPathaiQuantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Total quantity must be greater than 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      // Pathai form validation
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
    final workQuantity = widget.workType == 'Nikasi' 
        ? totalQuantity 
        : (widget.workType == 'Bharai' ? totalPathaiQuantity : quantity);
    
    // Fetch rate for selected labour from ledger entries
    final workRate = selectedLabour != null 
        ? LabourData.getRateForLabour(selectedLabour!)
        : LabourData.getDefaultRate();
    
    // Calculate amount = rate * quantity
    final workAmount = workQuantity * workRate;

    return LabourWork(
      id: WorkDataService.generateId(),
      labourName: selectedLabour!,
      labourCategory: workType,
      quantity: workQuantity,
      percentage: percentage,
      rate: workRate, // Fetched from ledger entries mapping
      totalAmount: workAmount, // Calculated as rate * quantity
      date: DateTime.now(),
    );
  }

  // Build widget for a single Pathai Labour Entry
  Widget _buildPathaiLabourEntry(PathaiLabourEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pathai Labour Entry ${pathaiLabourEntries.indexOf(entry) + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _removePathaiLabourEntry(entry.id),
                tooltip: 'Remove Entry',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Pathai Thekedar Dropdown
          CustomDropdown(
            label: 'Pathai Thekedar',
            labelHindi: 'पठाई ठेकेदार',
            hint: 'Select Pathai Thekedar',
            hintHindi: 'पठाई ठेकेदार चुनें',
            value: entry.pathaiThekedar,
            items: LabourData.getThekedarNames(labourType: 'Pathai'),
            onChanged: (value) {
              setState(() {
                entry.pathaiThekedar = value;
                entry.pathaiLabourName = null; // Reset labour when thekedar changes
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Pathai Labour Name Dropdown
          CustomDropdown(
            label: 'Pathai Labour Name',
            labelHindi: 'पठाई श्रमिक का नाम',
            hint: 'Select Pathai Labour',
            hintHindi: 'पठाई श्रमिक चुनें',
            value: entry.pathaiLabourName,
            items: getPathaiLabourNames(entry.pathaiThekedar),
            onChanged: (value) {
              setState(() {
                entry.pathaiLabourName = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Quantity Field for this entry
          FormTextField(
            label: 'Quantity *',
            labelHindi: 'मात्रा *',
            hint: 'Enter quantity',
            hintHindi: 'मात्रा दर्ज करें',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final qty = double.tryParse(value) ?? 0.0;
              setState(() {
                entry.quantity = qty;
              });
              _calculateTotal(); // Recalculate total amount
            },
          ),
        ],
      ),
    );
  }

  // Build widget for a single Brick Entry
  Widget _buildBrickEntry(BrickEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brick Entry ${brickEntries.indexOf(entry) + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _removeBrickEntry(entry.id),
                tooltip: 'Remove Entry',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Brick Type Dropdown
          CustomDropdown(
            label: 'Brick Type',
            labelHindi: 'ईंट का प्रकार',
            hint: 'Select Brick Type',
            hintHindi: 'ईंट का प्रकार चुनें',
            value: entry.brickType,
            items: brickTypes,
            onChanged: (value) {
              setState(() {
                entry.brickType = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Quantity Field for this entry
          FormTextField(
            label: 'Quantity *',
            labelHindi: 'मात्रा *',
            hint: 'Enter quantity',
            hintHindi: 'मात्रा दर्ज करें',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final qty = double.tryParse(value) ?? 0.0;
              setState(() {
                entry.quantity = qty;
              });
              _calculateTotal(); // Recalculate total amount
            },
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      selectedThekedar = null;
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
      pathaiLabourEntries.clear();
      brickEntries.clear();
    });
  }
}
