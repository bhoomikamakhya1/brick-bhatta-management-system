import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String labelHindi;
  final String? hint;
  final String? value;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.labelHindi,
    this.hint,
    this.value,
    this.keyboardType,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          labelHindi,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: readOnly ? Colors.grey.shade50 : Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? const Color(0xFF333333) : Colors.grey[500],
                    ),
                  ),
                ),
                if (suffix != null) suffix!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
