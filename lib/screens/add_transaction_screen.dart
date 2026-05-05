import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/sale_model.dart';
import '../data/user_data.dart';
import '../models/user_model.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/form_text_field.dart';
import '../services/sale_data_service.dart';
import '../services/sms_service.dart';
import '../services/auth_service.dart';
import 'dart:math';

class AddTransactionScreen extends StatefulWidget {
  final String? transactionType;
  
  const AddTransactionScreen({super.key, this.transactionType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _purchaseCategoryController = TextEditingController();

  bool _isAnonymous = false;
  bool _isCredit = true;
  String? _selectedCategory;
  String? _selectedParty;
  String? _selectedEmployee; // For Salaries
  String? _selectedVendor; // For Purchase

  // Sale form specific state
  String? _selectedCustomer; // Customer name
  UserModel? _selectedCustomerModel; // Full customer model
  List<BrickEntry> _brickEntries = [];
  final TextEditingController _advancePaymentController = TextEditingController();
  String? _freightType; // 'self' or 'sending'
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();
  final TextEditingController _freightRateController = TextEditingController();

  // Brick types list
  final List<String> _brickTypes = [
    'Awwal / अव्वल',
    'Doyam / दोयम',
    'Talsa / तलसा',
    'Chatka / चटका',
    'Kaccha Peela / कच्चा पीला',
    'Pakka Peela / पक्का पीला',
  ];

  // Get customers for Sale (from UserData with role Sale)
  List<UserModel> get _saleCustomers {
    final allUsers = UserData.getUsers();
    return allUsers
        .where((user) => user.role.toLowerCase() == 'sale')
        .toList();
  }

  List<String> get _customerNames {
    return _saleCustomers.map((user) => user.name).toList();
  }

  // Calculate total bricks quantity
  double get _totalBricksQuantity {
    return _brickEntries.fold(0.0, (sum, entry) => sum + entry.quantity);
  }

  // Calculate total amount from brick entries
  double get _bricksTotalAmount {
    return _brickEntries.fold(0.0, (sum, entry) => sum + (entry.quantity * entry.price));
  }

  // Calculate freight amount
  double get _freightAmount {
    if (_freightType == null || _freightType!.isEmpty) return 0.0;
    final rate = double.tryParse(_freightRateController.text) ?? 0.0;
    return (_totalBricksQuantity / 1000) * rate;
  }

  // Calculate final total (bricks total + freight - advance)
  double get _finalTotalAmount {
    return _bricksTotalAmount + _freightAmount - (double.tryParse(_advancePaymentController.text) ?? 0.0);
  }

  // Get all employees for Salaries (Labour, Employee, Thekedaar, Muneem)
  List<UserModel> get _allEmployees {
    final allUsers = UserData.getUsers();
    return allUsers.where((user) {
      final role = user.role.toLowerCase();
      return role == 'labour' || 
             role == 'employee' || 
             role == 'thekedaar' || 
             role == 'muneem' ||
             role == 'worker' ||
             role == 'supervisor' ||
             role == 'manager';
    }).toList();
  }

  // Get employee names for dropdown
  List<String> get _employeeNames {
    return _allEmployees.map((user) => user.name).toList();
  }

  // Get parties for Sale (from UserData with role Sale or Purchase)
  List<String> get _saleParties {
    final allUsers = UserData.getUsers();
    return allUsers
        .where((user) => user.role.toLowerCase() == 'sale' || user.role.toLowerCase() == 'purchase')
        .map((user) => user.name)
        .toList();
  }

  // Get vendors for Purchase (from UserData with role Purchase)
  List<UserModel> get _purchaseVendors {
    final allUsers = UserData.getUsers();
    return allUsers
        .where((user) => user.role.toLowerCase() == 'purchase')
        .toList();
  }

  List<String> get _vendorNames {
    return _purchaseVendors.map((user) => user.name).toList();
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
    _freightRateController.addListener(_updateCalculations);
    _advancePaymentController.addListener(_updateCalculations);
  }

  void _updateCalculations() {
    setState(() {});
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    _partyController.dispose();
    _purchaseCategoryController.dispose();
    _advancePaymentController.dispose();
    _vehicleNumberController.dispose();
    _vehicleNameController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _freightRateController.dispose();
    super.dispose();
  }

  // Add brick entry
  void _addBrickEntry() {
    setState(() {
      _brickEntries.add(BrickEntry(
        brickType: _brickTypes.first,
        quantity: 0.0,
        price: 0.0,
      ));
    });
  }

  // Remove brick entry
  void _removeBrickEntry(String id) {
    setState(() {
      _brickEntries.removeWhere((entry) => entry.id == id);
    });
  }

  // Generate OTP
  String _generateOTP() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // 4-digit OTP
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.transactionType != null 
            ? 'Add ${widget.transactionType} Transaction'
            : 'Add Transaction',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: widget.transactionType == 'Salaries'
                    ? _buildSalariesForm()
                    : widget.transactionType == 'Sale'
                    ? _buildSaleForm()
                    : widget.transactionType == 'Purchase'
                    ? _buildPurchaseForm()
                    : _buildGenericForm(),
                ),
              ),

              const SizedBox(height: 20),

              // Attachment Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Receipt/Document',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Upload Receipt/Document',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implement file upload
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B4513),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text('Choose File'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool isRequired = false,
    bool readOnly = false,
    int maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: suffixIcon,
          ),
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildTypeToggle({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Build Salaries Form
  Widget _buildSalariesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Field
        FormTextField(
          label: 'Date',
          labelHindi: 'तारीख',
          hint: 'Select Date',
          hintHindi: 'तारीख चुनें',
          value: _dateController.text,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _dateController.text = _formatDate(date);
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Employee Selection
        CustomDropdown(
          label: 'Employee',
          labelHindi: 'कर्मचारी',
          hint: 'Select Employee',
          hintHindi: 'कर्मचारी चुनें',
          value: _selectedEmployee,
          items: _employeeNames,
          onChanged: (value) {
            setState(() {
              _selectedEmployee = value;
            });
          },
        ),

        const SizedBox(height: 16),

        // Amount Field
        FormTextField(
          label: 'Amount',
          labelHindi: 'राशि',
          hint: 'Enter amount',
          hintHindi: 'राशि दर्ज करें',
          keyboardType: TextInputType.number,
          controller: _amountController,
        ),

        const SizedBox(height: 16),

        // Transaction Type (Always Debit for Salaries)
        const Text(
          'Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        _buildTypeToggle(
          label: 'Debit',
          isSelected: true,
          color: const Color(0xFF9E9E9E),
          onTap: () {
            setState(() {
              _isCredit = false;
            });
          },
        ),

        const SizedBox(height: 16),

        // Remarks Field
        FormTextField(
          label: 'Remarks (Optional)',
          labelHindi: 'टिप्पणी (वैकल्पिक)',
          hint: 'Add remarks',
          hintHindi: 'टिप्पणी जोड़ें',
          controller: _remarksController,
          maxLines: 3,
        ),
      ],
    );
  }

  // Build Sale Form
  Widget _buildSaleForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Field
        FormTextField(
          label: 'Date',
          labelHindi: 'तारीख',
          hint: 'Select Date',
          hintHindi: 'तारीख चुनें',
          value: _dateController.text,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _dateController.text = _formatDate(date);
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Customer Name Selection
        CustomDropdown(
          label: 'Customer Name',
          labelHindi: 'ग्राहक का नाम',
          hint: 'Select Customer',
          hintHindi: 'ग्राहक चुनें',
          value: _selectedCustomer,
          items: _customerNames,
          onChanged: (value) {
            setState(() {
              _selectedCustomer = value;
              _selectedCustomerModel = _saleCustomers.firstWhere(
                (c) => c.name == value,
                orElse: () => _saleCustomers.first,
              );
            });
          },
        ),

        // Show Address and Phone Number (read-only) after customer selection
        if (_selectedCustomerModel != null) ...[
          const SizedBox(height: 16),
          FormTextField(
            label: 'Address',
            labelHindi: 'पता',
            value: _selectedCustomerModel!.address ?? 'Not available',
            readOnly: true,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Phone Number',
            labelHindi: 'फोन नंबर',
            value: _selectedCustomerModel!.phoneNumber ?? 'Not available',
            readOnly: true,
          ),
        ],

        const SizedBox(height: 20),

        // Brick Entries Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Brick Entries',
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

        // List of Brick Entries
        ..._brickEntries.map((entry) => _buildBrickEntryWidget(entry)).toList(),

        if (_brickEntries.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Click + to add brick entries',
              style: TextStyle(color: Colors.grey),
            ),
          ),

        // Total Bricks Quantity
        if (_brickEntries.isNotEmpty) ...[
          const SizedBox(height: 16),
          FormTextField(
            label: 'Total Bricks Quantity',
            labelHindi: 'कुल ईंटों की मात्रा',
            value: _totalBricksQuantity.toStringAsFixed(0),
            readOnly: true,
          ),
        ],

        const SizedBox(height: 20),

        // Advance Payment
        FormTextField(
          label: 'Advance Payment',
          labelHindi: 'अग्रिम भुगतान',
          hint: 'Enter advance payment',
          hintHindi: 'अग्रिम भुगतान दर्ज करें',
          keyboardType: TextInputType.number,
          controller: _advancePaymentController,
        ),

        const SizedBox(height: 20),

        // Freight Section
        const Text(
          'Freight',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeToggle(
                label: 'Self',
                isSelected: _freightType == 'self',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  setState(() {
                    _freightType = 'self';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeToggle(
                label: 'Sending',
                isSelected: _freightType == 'sending',
                color: const Color(0xFF2196F3),
                onTap: () {
                  setState(() {
                    _freightType = 'sending';
                  });
                },
              ),
            ),
          ],
        ),

        if (_freightType == 'self') ...[
          const SizedBox(height: 16),
          FormTextField(
            label: 'Vehicle Number',
            labelHindi: 'वाहन नंबर',
            hint: 'Enter vehicle number',
            hintHindi: 'वाहन नंबर दर्ज करें',
            controller: _vehicleNumberController,
          ),
        ],

        if (_freightType == 'sending') ...[
          const SizedBox(height: 16),
          FormTextField(
            label: 'Vehicle Name',
            labelHindi: 'वाहन का नाम',
            hint: 'Enter vehicle name',
            hintHindi: 'वाहन का नाम दर्ज करें',
            controller: _vehicleNameController,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Vehicle Number',
            labelHindi: 'वाहन नंबर',
            hint: 'Enter vehicle number',
            hintHindi: 'वाहन नंबर दर्ज करें',
            controller: _vehicleNumberController,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Driver Name',
            labelHindi: 'चालक का नाम',
            hint: 'Enter driver name',
            hintHindi: 'चालक का नाम दर्ज करें',
            controller: _driverNameController,
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Driver Phone',
            labelHindi: 'चालक का फोन',
            hint: 'Enter driver phone',
            hintHindi: 'चालक का फोन दर्ज करें',
            keyboardType: TextInputType.phone,
            controller: _driverPhoneController,
          ),
        ],

        if (_freightType != null && _freightType!.isNotEmpty) ...[
          const SizedBox(height: 16),
          FormTextField(
            label: 'Freight Rate (per 1000 bricks)',
            labelHindi: 'माल ढुलाई दर (प्रति 1000 ईंट)',
            hint: 'Enter freight rate',
            hintHindi: 'माल ढुलाई दर दर्ज करें',
            keyboardType: TextInputType.number,
            controller: _freightRateController,
          ),
          const SizedBox(height: 12),
          FormTextField(
            label: 'Freight Amount',
            labelHindi: 'माल ढुलाई राशि',
            value: '₹${_freightAmount.toStringAsFixed(2)}',
            readOnly: true,
          ),
        ],

        const SizedBox(height: 20),

        // Total Amount Display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF8B4513)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bricks Total:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${_bricksTotalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (_freightAmount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Freight:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹${_freightAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              if ((double.tryParse(_advancePaymentController.text) ?? 0.0) > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Advance Paid:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹${(double.tryParse(_advancePaymentController.text) ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ],
                ),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Final Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${_finalTotalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Remarks Field
        FormTextField(
          label: 'Remarks (Optional)',
          labelHindi: 'टिप्पणी (वैकल्पिक)',
          hint: 'Add remarks',
          hintHindi: 'टिप्पणी जोड़ें',
          controller: _remarksController,
          maxLines: 3,
        ),
      ],
    );
  }

  // Build widget for a single Brick Entry
  Widget _buildBrickEntryWidget(BrickEntry entry) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brick Entry ${_brickEntries.indexOf(entry) + 1}',
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
          CustomDropdown(
            label: 'Brick Type',
            labelHindi: 'ईंट का प्रकार',
            hint: 'Select Brick Type',
            hintHindi: 'ईंट का प्रकार चुनें',
            value: entry.brickType,
            items: _brickTypes,
            onChanged: (value) {
              setState(() {
                entry.brickType = value ?? _brickTypes.first;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: entry.quantity > 0 ? entry.quantity.toStringAsFixed(0) : '',
            decoration: const InputDecoration(
              labelText: 'Quantity / मात्रा',
              hintText: 'Enter quantity / मात्रा दर्ज करें',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                entry.quantity = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: entry.price > 0 ? entry.price.toStringAsFixed(2) : '',
            decoration: const InputDecoration(
              labelText: 'Price per Unit / प्रति यूनिट मूल्य',
              hintText: 'Enter price / मूल्य दर्ज करें',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                entry.price = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '₹${(entry.quantity * entry.price).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Purchase Form
  Widget _buildPurchaseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Field
        FormTextField(
          label: 'Date',
          labelHindi: 'तारीख',
          hint: 'Select Date',
          hintHindi: 'तारीख चुनें',
          value: _dateController.text,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _dateController.text = _formatDate(date);
              });
            }
          },
        ),

        const SizedBox(height: 16),

      // Vendor Name Selection
      CustomDropdown(
        label: 'Vendor Name',
        labelHindi: 'विक्रेता का नाम',
        hint: 'Select Vendor',
        hintHindi: 'विक्रेता चुनें',
        value: _selectedVendor,
        items: _vendorNames,
        onChanged: (value) {
          setState(() {
            _selectedVendor = value;
          });
        },
      ),

      const SizedBox(height: 16),

      // Category Input Field (Transport, Fuel, Maintenance, raw materials)
      FormTextField(
        label: 'Category',
        labelHindi: 'श्रेणी',
        hint: 'Enter category (Transport, Fuel, Maintenance, Raw Materials)',
        hintHindi: 'श्रेणी दर्ज करें (ट्रांसपोर्ट, ईंधन, रखरखाव, कच्चा माल)',
        controller: _purchaseCategoryController,
      ),

        const SizedBox(height: 16),

        // Amount Field
        FormTextField(
          label: 'Amount',
          labelHindi: 'राशि',
          hint: 'Enter amount',
          hintHindi: 'राशि दर्ज करें',
          keyboardType: TextInputType.number,
          controller: _amountController,
        ),

        const SizedBox(height: 16),

        // Transaction Type (Always Debit for Purchase)
        const Text(
          'Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        _buildTypeToggle(
          label: 'Debit',
          isSelected: true,
          color: const Color(0xFF9E9E9E),
          onTap: () {
            setState(() {
              _isCredit = false;
            });
          },
        ),

        const SizedBox(height: 16),

        // Remarks Field
        FormTextField(
          label: 'Remarks (Optional)',
          labelHindi: 'टिप्पणी (वैकल्पिक)',
          hint: 'Add remarks',
          hintHindi: 'टिप्पणी जोड़ें',
          controller: _remarksController,
          maxLines: 3,
        ),
      ],
    );
  }

  // Build Generic Form (fallback)
  Widget _buildGenericForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Field
        _buildTextField(
          label: 'Date',
          isRequired: true,
          controller: _dateController,
          hint: '15-01-2024',
          suffixIcon: const Icon(Icons.calendar_today),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              _dateController.text = _formatDate(date);
            }
          },
        ),

        const SizedBox(height: 20),

        // Amount Field
        _buildTextField(
          label: 'Amount',
          isRequired: true,
          controller: _amountController,
          hint: '₹0.00',
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 20),

        // Transaction Type
        const Text(
          'Type',
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
              child: _buildTypeToggle(
                label: 'Credit',
                isSelected: _isCredit,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  setState(() {
                    _isCredit = true;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeToggle(
                label: 'Debit',
                isSelected: !_isCredit,
                color: const Color(0xFF9E9E9E),
                onTap: () {
                  setState(() {
                    _isCredit = false;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Remarks Field
        _buildTextField(
          label: 'Remarks',
          controller: _remarksController,
          hint: 'Add remarks (optional)',
          maxLines: 3,
        ),
      ],
    );
  }

  Future<void> _saveTransaction() async {
    // Validate amount
    if (_amountController.text.trim().isEmpty && widget.transactionType!="Sale") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    // if (amount == null || amount <= 0 && widget.transactionType!="Sale") {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please enter a valid amount'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

      String hindiName;
    String englishName;
    String category;

    if (widget.transactionType == 'Salaries') {
      // For Salaries
      if (_selectedEmployee == null || _selectedEmployee!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an employee'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final employee = _allEmployees.firstWhere(
        (e) => e.name == _selectedEmployee,
        orElse: () => _allEmployees.first,
      );
      hindiName = employee.nameHindi;
      englishName = employee.name;
      category = 'Salaries';
      _isCredit = false; // Salaries are always debit
    } else if (widget.transactionType == 'Sale') {
      // For Sale - validate all required fields
      if (_selectedCustomer == null || _selectedCustomer!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a customer'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_brickEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one brick entry'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate all brick entries have type, quantity, and price
      for (var entry in _brickEntries) {
        if (entry.brickType == null || entry.brickType!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select brick type for all entries'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (entry.quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter valid quantity for all entries'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (entry.price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter valid price for all entries'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Parse date
      final dateParts = _dateController.text.split('-');
      final saleDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      // Create freight details
      FreightDetails? freightDetails;
      if (_freightType != null && _freightType!.isNotEmpty) {
        freightDetails = FreightDetails(
          type: _freightType!,
          vehicleNumber: _vehicleNumberController.text.trim().isNotEmpty ? _vehicleNumberController.text.trim() : null,
          vehicleName: _freightType == 'sending' && _vehicleNameController.text.trim().isNotEmpty ? _vehicleNameController.text.trim() : null,
          driverName: _freightType == 'sending' && _driverNameController.text.trim().isNotEmpty ? _driverNameController.text.trim() : null,
          driverPhone: _freightType == 'sending' && _driverPhoneController.text.trim().isNotEmpty ? _driverPhoneController.text.trim() : null,
          ratePer1000: double.tryParse(_freightRateController.text) ?? 0.0,
        );
      }

      // Generate OTP
      final otp = _generateOTP();

      // Create SaleEntry
      final saleEntry = SaleEntry(
        customerName: _selectedCustomerModel!.name,
        customerNameHindi: _selectedCustomerModel!.nameHindi,
        customerAddress: _selectedCustomerModel!.address,
        customerPhone: _selectedCustomerModel!.phoneNumber,
        date: saleDate,
        time: DateTime.now(),
        brickEntries: _brickEntries,
        advancePayment: double.tryParse(_advancePaymentController.text) ?? 0.0,
        freightDetails: freightDetails,
        totalAmount: _bricksTotalAmount + _freightAmount,
        finalAmount: _finalTotalAmount,
        remarks: _remarksController.text.trim().isNotEmpty ? _remarksController.text.trim() : null,
        otp: otp,
        createdBy: await AuthService().getUserId() ?? 'unknown_user',
      );


      // Save sale entry to storage
      SaleDataService.addSale(saleEntry);

      // Send SMS with OTP and details
      bool smsSent = false;
      if (saleEntry.customerPhone != null && saleEntry.customerPhone!.isNotEmpty) {
        try {
          smsSent = await SmsService.sendSaleConfirmationSms(saleEntry);
        } catch (e) {
          print('Error sending SMS: $e');
        }
      }

      // Show success message with OTP
      final smsStatus = smsSent 
          ? 'SMS sent to customer.' 
          : (saleEntry.customerPhone == null || saleEntry.customerPhone!.isEmpty)
              ? 'No phone number available for SMS.'
              : 'SMS could not be sent.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sale saved successfully! OTP: $otp'),
              const SizedBox(height: 4),
              Text(
                smsStatus,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Create a TransactionItem from the sale entry for the transactions list
      final transactionItem = TransactionItem(
        hindiName: saleEntry.customerNameHindi,
        englishName: saleEntry.customerName,
        amount: saleEntry.finalAmount,
        type: TransactionType.credit, // Sales are credit (money coming in)
        date: _dateController.text,
        category: 'Sale',
      );

      // Navigate back with the transaction item
      Navigator.pop(context, transactionItem);
      return;
    } else if (widget.transactionType == 'Purchase') {
      // For Purchase
      if (_purchaseCategoryController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      hindiName = _purchaseCategoryController.text.trim();
      englishName = _purchaseCategoryController.text.trim();
      category = _purchaseCategoryController.text.trim();
      _isCredit = false; // Purchases are always debit
    } else {
      // Generic form (fallback)
      if (_isAnonymous) {
        hindiName = 'अज्ञात';
        englishName = 'Anonymous';
      } else {
            hindiName = _selectedParty ?? 'अज्ञात पार्टी';
        englishName = _selectedParty ?? 'Unknown Party';
        }
      category = _selectedCategory ?? 'Other';
      }

      final newTransaction = TransactionItem(
        hindiName: hindiName,
      englishName: englishName,
      amount: amount,
        type: _isCredit ? TransactionType.credit : TransactionType.debit,
        date: _dateController.text,
      category: category,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back with the new transaction
      Navigator.pop(context, newTransaction);
  }
}

