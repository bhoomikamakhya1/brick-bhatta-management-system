import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();

  bool _isAnonymous = false;
  bool _isCredit = true;
  String? _selectedCategory;
  String? _selectedParty;

  final List<String> _categories = [
    'Sales',
    'Purchase',
    'Labor Payment',
    'Transport',
    'Fuel',
    'Maintenance',
    'Equipment',
    'Utilities',
  ];

  final List<String> _parties = [
    'Raj Brick Kiln',
    'Sharma Construction',
    'Gupta Transport',
    'Patel Builders',
    'Singh Enterprises',
    'Kumar Suppliers',
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    _partyController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(
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
                  child: Column(
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

                      // Party Selection
                      const Text(
                        'Party',
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
                            child: RadioListTile<bool>(
                              title: const Text('Select Party'),
                              value: false,
                              groupValue: _isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  _isAnonymous = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Anonymous'),
                              value: true,
                              groupValue: _isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  _isAnonymous = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),

                      if (!_isAnonymous) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedParty,
                          decoration: const InputDecoration(
                            hintText: 'Select Party',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          items: _parties.map((String party) {
                            return DropdownMenuItem<String>(
                              value: party,
                              child: Text(party),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedParty = value;
                            });
                          },
                          validator: (value) {
                            if (!_isAnonymous && (value == null || value.isEmpty)) {
                              return 'Please select a party';
                            }
                            return null;
                          },
                        ),
                      ],

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

                      // Category Field
                      _buildDropdownField(
                        label: 'Category',
                        isRequired: true,
                        value: _selectedCategory,
                        items: _categories,
                        hint: 'Select Category',
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
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
                  ),
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

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      // Create new transaction with proper Hindi names
      String hindiName;
      if (_isAnonymous) {
        hindiName = 'अज्ञात';
      } else {
        // Map English party names to Hindi
        switch (_selectedParty) {
          case 'Raj Brick Kiln':
            hindiName = 'राज ईंट भट्टा';
            break;
          case 'Sharma Construction':
            hindiName = 'शर्मा कंस्ट्रक्शन';
            break;
          case 'Gupta Transport':
            hindiName = 'गुप्ता ट्रांसपोर्ट';
            break;
          case 'Patel Builders':
            hindiName = 'पटेल बिल्डर्स';
            break;
          case 'Singh Enterprises':
            hindiName = 'सिंह एंटरप्राइजेज';
            break;
          default:
            hindiName = _selectedParty ?? 'अज्ञात पार्टी';
        }
      }

      final newTransaction = TransactionItem(
        hindiName: hindiName,
        englishName: _isAnonymous ? 'Anonymous' : (_selectedParty ?? 'Unknown Party'),
        amount: double.tryParse(_amountController.text) ?? 0.0,
        type: _isCredit ? TransactionType.credit : TransactionType.debit,
        date: _dateController.text,
        category: _selectedCategory ?? 'Other',
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
}

