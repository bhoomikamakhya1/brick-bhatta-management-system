import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/labour_work_model.dart';
import '../services/user_sync_bridge.dart';

class LedgerDetailScreen extends StatefulWidget {
  final UserModel user;

  const LedgerDetailScreen({super.key, required this.user});

  @override
  State<LedgerDetailScreen> createState() => _LedgerDetailScreenState();
}

class _LedgerDetailScreenState extends State<LedgerDetailScreen> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ledger Detail / खाता विवरण',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _infoSection(
              title: 'Basic Information / मूल जानकारी',
              children: [
                _readonlyField('Party Name / पार्टी नाम', user.name),
                _readonlyField('Name (Hindi) / हिंदी नाम', user.nameHindi),
                _readonlyField('Role / भूमिका', user.role),
                _readonlyField(
                  'Status / स्थिति',
                  user.isActive ? 'Active / सक्रिय' : 'Inactive / निष्क्रिय',
                  valueColor: user.isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoSection(
              title: 'Contact Information / संपर्क जानकारी',
              children: [
                _readonlyField('Contact Person / संपर्क व्यक्ति', user.contactPerson ?? '—'),
                _readonlyField('Phone Number / फोन नंबर', user.phoneNumber ?? '—'),
                _readonlyField('Address / पता', user.address ?? '—'),
              ],
            ),
            const SizedBox(height: 16),
            _infoSection(
              title: 'Party Details / पार्टी विवरण',
              children: [
                _readonlyField('Party Type / पार्टी प्रकार', user.partyType ?? '—'),
                _readonlyField('GST Number / जीएसटी नंबर', user.gstNumber ?? '—'),
              ],
            ),
            const SizedBox(height: 16),
            _infoSection(
              title: 'Financial Information / वित्तीय जानकारी',
              children: [
                _readonlyField(
                  'Opening Balance / प्रारंभिक शेष',
                  user.openingBalance != null
                      ? '\u20b9${user.openingBalance!.toStringAsFixed(0)} ${user.openingBalanceType ?? 'Cr'}'
                      : '—',
                  valueColor: user.openingBalanceType == 'Dr' ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                ),
                _readonlyField(
                  'Credit Limit / क्रेडिट लिमिट',
                  user.creditLimit != null ? '\u20b9${user.creditLimit!.toStringAsFixed(0)}' : '—',
                ),
                if (user.role.toLowerCase() == 'labour')
                  _readonlyField(
                    'Rate /1000 (दर प्रति 1000)',
                    '\u20b9${LabourData.getRateForLabour(user.name).toStringAsFixed(2)}',
                    valueColor: const Color(0xFF8B4513),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513).withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nameHindi,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoSection({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _EditPartyScreen(user: user),
                ),
              );
              if (!mounted) return;
              if (result is UserModel) {
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8B4513)),
                    ),
                  );

                  // Update user in both local storage and database
                  await UserSyncBridge.updateUser(result);
                  
                  // Close loading dialog
                  if (mounted) Navigator.of(context).pop();
                  
                  // Update local state
                  setState(() {
                    user = result;
                  });
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${result.name} updated successfully'),
                        backgroundColor: const Color(0xFF4CAF50),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  
                  // Return updated user to previous screen
                  Navigator.of(context).pop<UserModel>(result);
                  
                } catch (e) {
                  // Close loading dialog if still open
                  if (mounted) Navigator.of(context).pop();
                  
                  // Show error message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: ${e.toString()}'),
                        backgroundColor: const Color(0xFFF44336),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text(
              'Edit Details / विवरण संपादित करें',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Party'),
                  content: Text('Are you sure you want to delete ${user.name}?\\n\\nThis action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFF44336)),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8B4513)),
                    ),
                  );

                  // Remove user from both local storage and database
                  await UserSyncBridge.removeUser(user.id);
                  
                  // Close loading dialog
                  if (mounted) Navigator.of(context).pop();
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${user.name} deleted successfully'),
                        backgroundColor: const Color(0xFF4CAF50),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  
                  // Return to previous screen
                  Navigator.of(context).pop();
                  
                } catch (e) {
                  // Close loading dialog if still open
                  if (mounted) Navigator.of(context).pop();
                  
                  // Show error message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete: ${e.toString()}'),
                        backgroundColor: const Color(0xFFF44336),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF44336),
              side: const BorderSide(color: Color(0xFFF44336)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text(
              'Delete / हटाएं',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditPartyScreen extends StatefulWidget {
  final UserModel user;
  const _EditPartyScreen({required this.user});

  @override
  State<_EditPartyScreen> createState() => _EditPartyScreenState();
}

class _EditPartyScreenState extends State<_EditPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nameHindiController;
  late String _role;
  bool _isActive = true;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late String _partyType;
  late TextEditingController _gstController;
  late TextEditingController _openingBalanceController;
  String _openingBalanceType = 'Cr';
  late TextEditingController _creditLimitController;
  late TextEditingController _rateController;

  final List<String> _roles = const ['Labour', 'Thekedaar', 'Employee', 'Sale', 'Purchase', 'Supervisor', 'Worker', 'Manager', 'General'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _nameHindiController = TextEditingController(text: widget.user.nameHindi);
    _role = widget.user.role;
    _isActive = widget.user.isActive;
    _contactPersonController = TextEditingController(text: widget.user.contactPerson ?? '');
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _partyType = widget.user.partyType ?? 'Customer';
    _gstController = TextEditingController(text: widget.user.gstNumber ?? '');
    _openingBalanceController = TextEditingController(text: widget.user.openingBalance?.toStringAsFixed(0) ?? '');
    _openingBalanceType = widget.user.openingBalanceType ?? 'Cr';
    _creditLimitController = TextEditingController(text: widget.user.creditLimit?.toStringAsFixed(0) ?? '');
    final existingRate = LabourData.getRateForLabour(widget.user.name);
    _rateController = TextEditingController(text: widget.user.role.toLowerCase() == 'labour' ? existingRate.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameHindiController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _openingBalanceController.dispose();
    _creditLimitController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    if (_role.toLowerCase() == 'labour') {
      final rateText = _rateController.text.trim();
      if (rateText.isNotEmpty) {
        final rate = double.tryParse(rateText);
        if (rate != null && rate > 0) {
          LabourData.setRateForLabour(name, rate);
        }
      }
    }
    final updated = UserModel(
      id: widget.user.id,
      name: _nameController.text.trim(),
      nameHindi: _nameHindiController.text.trim().isEmpty ? _nameController.text.trim() : _nameHindiController.text.trim(),
      role: _role,
      roleHindi: widget.user.roleHindi,
      isActive: _isActive,
      initials: _computeInitials(_nameController.text.trim()),
      contactPerson: _contactPersonController.text.trim().isEmpty ? null : _contactPersonController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      partyType: _partyType,
      gstNumber: _gstController.text.trim().isEmpty ? null : _gstController.text.trim(),
      openingBalance: _openingBalanceController.text.trim().isEmpty ? null : double.tryParse(_openingBalanceController.text.trim()),
      openingBalanceType: _openingBalanceType,
      creditLimit: _creditLimitController.text.trim().isEmpty ? null : double.tryParse(_creditLimitController.text.trim()),
    );
    Navigator.of(context).pop(updated);
  }

  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r"\\s+"));
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Party / पार्टी संपादित करें',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Party Name / पार्टी नाम', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Name (Hindi) / हिंदी नाम', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameHindiController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Contact Person / संपर्क व्यक्ति', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _contactPersonController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Phone Number / फोन नंबर', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Address / पता', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Party Type / पार्टी प्रकार', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _partyType,
                    items: const [
                      DropdownMenuItem<String>(value: 'Customer', child: Text('Customer / ग्राहक')),
                      DropdownMenuItem<String>(value: 'Supplier', child: Text('Supplier / सप्लायर')),
                    ],
                    onChanged: (v) => setState(() => _partyType = v ?? _partyType),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('GST Number / जीएसटी नंबर', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Opening Balance / प्रारंभिक शेष', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _openingBalanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: DropdownButtonFormField<String>(
                          value: _openingBalanceType,
                          items: const [
                            DropdownMenuItem<String>(value: 'Dr', child: Text('Dr')),
                            DropdownMenuItem<String>(value: 'Cr', child: Text('Cr')),
                          ],
                          onChanged: (v) => setState(() => _openingBalanceType = v ?? _openingBalanceType),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Credit Limit / क्रेडिट लिमिट', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _creditLimitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  if (_role.toLowerCase() == 'labour') ...[
                    const SizedBox(height: 16),
                    const Text('Rate /1000 (दर प्रति 1000)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _rateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        hintText: 'Enter rate per 1000 bricks',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active / सक्रिय'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF8B4513),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Update Party / पार्टी अपडेट करें',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B4513),
                        side: const BorderSide(color: Color(0xFF8B4513)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Cancel / रद्द करें',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
