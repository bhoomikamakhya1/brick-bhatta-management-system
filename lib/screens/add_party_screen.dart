import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_sync_bridge.dart';
import '../widgets/dialog_selector.dart';

class AddPartyScreen extends StatefulWidget {
  const AddPartyScreen({super.key});

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  final List<String> _groups = ['Labour', 'Thekedaar', 'Employee', 'Sale', 'Purchase', 'General'];
  String? _selectedGroup;

  // Labour-specific
  String? _selectedThekedaar;
  String? _selectedLabourType;
  final List<String> _thekedaarList = const [
    'Sunil Thekedaar',
    'Ramesh Thekedaar',
    'Suresh Thekedaar',
  ];
  final List<String> _labourTypes = const [
    'Pathai',
    'Bharai',
    'Nikasi',
  ];

  bool _typePathai = false;
  bool _typeBharai = false;
  bool _typeNikasi = false;

  DateTime? _joiningDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commissionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_isSaving) return; // Prevent multiple saves
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      print('🔍 Starting save process...');
      
      // Validate form first
      if (!_formKey.currentState!.validate()) {
        print('❌ Form validation failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
        );
        return;
      }
      
      print('✅ Form validation passed');
      
      // Build a lightweight user entry for the Ledger list
      final name = _nameController.text.trim();
      final group = _selectedGroup ?? 'General';
      final role = _toRole(group);
      final roleHi = _toHindi(group);
      final initials = _computeInitials(name);
      
      print('📝 Creating user: $name, Group: $group, Role: $role');
      
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        nameHindi: name, // for now mirror name
        role: role,
        roleHindi: roleHi,
        initials: initials,
        isActive: true,
      );
      
      print('👤 User model created: ${newUser.name}');
      
      // Add to both UserData and sync system
      await UserSyncBridge.addUser(newUser);
      
      print('✅ User added successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Party saved and synced'), backgroundColor: Colors.green),
        );
        
        // Navigate back after successful save
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Error saving party: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving party: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF8B4513)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add Party',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name* (नाम*)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter party name / पार्टी का नाम दर्ज करें',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF8B4513)),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Group* (समूह*)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 6),
                    DialogSelectorField(
                      title: 'Select Group / समूह चुनें',
                      hint: 'Select Group / समूह चुनें',
                      value: _selectedGroup,
                      options: _groups.map((g) => '${_toEnglish(g)} / ${_toHindi(g)}').toList(),
                      toValue: (display) => display.split(' / ').first,
                      toDisplay: (value) => '${_toEnglish(value)} / ${_toHindi(value)}',
                      onSelected: (selected) {
                        setState(() {
                          _selectedGroup = selected;
                          _selectedThekedaar = null;
                          _selectedLabourType = null;
                          _typePathai = false;
                          _typeBharai = false;
                          _typeNikasi = false;
                          _commissionController.clear();
                          _salaryController.clear();
                          _joiningDate = null;
                          _endDate = null;
                        });
                      },
                      validator: (_) => _selectedGroup == null ? 'Group is required' : null,
                    ),

                    const SizedBox(height: 16),

                    // Conditional sections based on group
                    if (_selectedGroup == 'Labour') ...[
                      const Text(
                        'Thekedaar (ठेकेदार)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedThekedaar,
                        isExpanded: true,
                        menuMaxHeight: 320,
                        items: _thekedaarList
                            .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedThekedaar = v),
                        decoration: _inputDecoration(
                          hint: 'Select Thekedaar / ठेकेदार चुनें',
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'Labour Type (मजदूर प्रकार)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedLabourType,
                        isExpanded: true,
                        menuMaxHeight: 320,
                        items: _labourTypes
                            .map((t) => DropdownMenuItem<String>(
                                  value: t,
                                  child: Text('$t / ${_toHindi(t)}'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedLabourType = v),
                        decoration: _inputDecoration(
                          hint: 'Select Type / प्रकार चुनें',
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),

                      const SizedBox(height: 12),
                      _commissionField(),
                    ] else if (_selectedGroup == 'Thekedaar') ...[
                      const Text(
                        'Type (प्रकार)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 6),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _typePathai,
                        onChanged: (v) => setState(() => _typePathai = v ?? false),
                        title: const Text('Pathai / पाथई', style: TextStyle(fontSize: 14)),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _typeBharai,
                        onChanged: (v) => setState(() => _typeBharai = v ?? false),
                        title: const Text('Bharai / भराई', style: TextStyle(fontSize: 14)),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _typeNikasi,
                        onChanged: (v) => setState(() => _typeNikasi = v ?? false),
                        title: const Text('Nikasi / निकासी', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(height: 8),
                      _commissionField(),
                    ] else if (_selectedGroup == 'Employee') ...[
                      const Text(
                        'Salary (वेतन)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _salaryController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(hint: 'Enter salary / वेतन दर्ज करें'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Joining Date (ज्वाइनिंग तारीख)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _joiningDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _joiningDate = picked);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration(
                              hint: _joiningDate == null ? 'dd-mm-yyyy' : _fmtDate(_joiningDate!),
                              suffixIcon: const Icon(Icons.calendar_today, size: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'End Date (समाप्ति तारीख)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration(
                              hint: _endDate == null ? 'dd-mm-yyyy' : _fmtDate(_endDate!),
                              suffixIcon: const Icon(Icons.calendar_today, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ] else if (_selectedGroup == 'General') ...[
                      _commissionField(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () async {
                        print('🔘 Save button pressed');
                        await _onSave();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save / सेव करें', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel / रद्द करें', style: TextStyle(color: Color(0xFF333333))),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _toHindi(String group) {
    switch (group.toLowerCase()) {
      case 'labour':
        return 'लेबर';
      case 'thekedaar':
        return 'ठेकेदार';
      case 'employee':
        return 'कर्मचारी';
      case 'sales':
        return 'सेल्स';
      case 'sale':
        return 'बिक्री';
      case 'purchase':
        return 'खरीद';
      case 'general':
        return 'सामान्य';
      default:
        return group;
    }
  }

  String _toRole(String group) {
    switch (group.toLowerCase()) {
      case 'labour':
        return 'Labour';
      case 'thekedaar':
        return 'Thekedaar';
      case 'employee':
        return 'Employee';
      case 'sale':
      case 'sales':
        return 'Sale';
      case 'purchase':
        return 'Purchase';
      case 'general':
      default:
        return 'General';
    }
  }

  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _toEnglish(String group) {
    switch (group.toLowerCase()) {
      case 'sales':
        return 'Sale';
      default:
        return group[0].toUpperCase() + group.substring(1);
    }
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd-$mm-$yyyy';
  }

  Widget _commissionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commission % (कमीशन %)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _commissionController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(hint: 'Enter commission % / कमीशन % दर्ज करें'),
        ),
      ],
    );
  }

  Future<String?> _showOptionsBottomSheet(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String Function(String display) toValue,
    String? initiallySelectedValue,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final display = options[index];
                    final value = toValue(display);
                    final selected = value == initiallySelectedValue;
                    return ListTile(
                      title: Text(display),
                      trailing: selected ? const Icon(Icons.check, color: Color(0xFF8B4513)) : null,
                      onTap: () => Navigator.of(context).pop(value),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


