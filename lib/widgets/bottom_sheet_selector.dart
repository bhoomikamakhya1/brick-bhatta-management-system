import 'package:flutter/material.dart';

class BottomSheetSelectorField extends StatelessWidget {
  final String title;
  final String hint;
  final String? value;
  final List<String> options;
  final String Function(String display) toValue;
  final String Function(String value)? toDisplay;
  final ValueChanged<String> onSelected;
  final FormFieldValidator<String>? validator;

  const BottomSheetSelectorField({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.options,
    required this.toValue,
    this.toDisplay,
    required this.onSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return GestureDetector(
          onTap: () async {
            final selected = await _showOptionsBottomSheet(
              context,
              title: title,
              options: options,
              toValue: toValue,
              initiallySelectedValue: state.value,
            );
            if (selected != null) {
              state.didChange(selected);
              onSelected(selected);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              decoration: _inputDecoration(
                hint: state.value == null
                    ? hint
                    : (toDisplay != null ? toDisplay!(state.value!) : state.value!),
                suffixIcon: const Icon(Icons.keyboard_arrow_down),
                errorText: state.errorText,
              ),
            ),
          ),
        );
      },
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

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      errorText: errorText,
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF8B4513)),
      ),
    );
  }
}


