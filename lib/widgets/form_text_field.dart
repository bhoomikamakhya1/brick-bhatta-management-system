import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  final String label;
  final String? labelHindi;
  final String? hint;
  final String? hintHindi;
  final String? value;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final Widget? suffixIcon;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final int? maxLines;

  const FormTextField({
    super.key,
    required this.label,
    this.labelHindi,
    this.hint,
    this.hintHindi,
    this.value,
    this.keyboardType,
    this.suffix,
    this.suffixIcon,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelHindi != null ? '$label / $labelHindi' : label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        readOnly 
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  if (suffix != null) suffix!,
                ],
              ),
            )
          : TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hintHindi != null ? '$hint / $hintHindi' : hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                suffixIcon: suffixIcon,
              ),
              onChanged: onChanged,
              onTap: onTap,
            ),
      ],
    );
  }
}
