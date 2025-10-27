import 'package:flutter/material.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountAmountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _freightController = TextEditingController();

  String? _selectedClient;
  String? _selectedCurrency = '₹';
  double _grossAmount = 0.0;
  double _netAmount = 0.0;

  final List<String> _clients = [
    'Raj Brick Kiln',
    'Sharma Construction',
    'Gupta Transport',
    'Patel Builders',
    'Singh Enterprises',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateAmounts);
    _priceController.addListener(_calculateAmounts);
    _discountAmountController.addListener(_calculateAmounts);
    _taxController.addListener(_calculateAmounts);
    _freightController.addListener(_calculateAmounts);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _discountAmountController.dispose();
    _taxController.dispose();
    _freightController.dispose();
    super.dispose();
  }

  void _calculateAmounts() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discount = double.tryParse(_discountAmountController.text) ?? 0.0;
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final freight = double.tryParse(_freightController.text) ?? 0.0;

    setState(() {
      _grossAmount = quantity * price;
      _netAmount = _grossAmount - discount + (_grossAmount * tax / 100) + freight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add Sale / बिक्री जोड़े',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // TODO: Show help information
            },
          ),
        ],
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
                      // Client Name Dropdown
                      _buildDropdownField(
                        label: 'Client Name / ग्राहक का नाम',
                        isRequired: true,
                        value: _selectedClient,
                        items: _clients,
                        hint: 'Select Client / ग्राहक चुनें',
                        onChanged: (value) {
                          setState(() {
                            _selectedClient = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // Quantity Field
                      _buildTextField(
                        label: 'Quantity (pcs) / मात्रा (पीस)',
                        isRequired: true,
                        controller: _quantityController,
                        hint: 'Enter quantity / मात्रा दर्ज करें',
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      // Price Field
                      _buildTextField(
                        label: 'Price per Brick (₹) / प्रति ईंट दर',
                        isRequired: true,
                        controller: _priceController,
                        hint: 'Enter price / दर दर्ज करें',
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      // Discount Section
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              label: 'Discount / छूट',
                              controller: _discountAmountController,
                              hint: 'Amount / राशि',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              items: const [
                                DropdownMenuItem(value: '₹', child: Text('₹')),
                                DropdownMenuItem(value: '\$', child: Text('\$')),
                                DropdownMenuItem(value: '€', child: Text('€')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCurrency = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Tax Field
                      _buildTextField(
                        label: 'Tax (%) / कर',
                        controller: _taxController,
                        hint: 'Enter tax percentage / कर प्रतिशत',
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      // Freight Field
                      _buildTextField(
                        label: 'Freight (₹) / परिवहन',
                        controller: _freightController,
                        hint: 'Enter freight charges / परिवहन शुल्क',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Calculation Card
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
                        'Calculation / गणना',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gross Amount / सकल राशि:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF666666),
                            ),
                          ),
                          Text(
                            '₹${_grossAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Amount / शुद्ध राशि:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF666666),
                            ),
                          ),
                          Text(
                            '₹${_netAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSale,
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
                        'Save Sale / बिक्री सेव करें',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B4513),
                        side: const BorderSide(color: Color(0xFF8B4513)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel / रद्द करें',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
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
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
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
              return 'Please select a client';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  void _saveSale() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save sale data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form
      _formKey.currentState!.reset();
      setState(() {
        _selectedClient = null;
        _grossAmount = 0.0;
        _netAmount = 0.0;
      });
    }
  }
}

