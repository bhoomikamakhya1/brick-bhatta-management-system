import 'package:flutter/material.dart';

class DialogSelectorField extends StatelessWidget {
  final String title;
  final String hint;
  final String? value;
  final List<String> options; // display strings
  final String Function(String display) toValue;
  final String Function(String value)? toDisplay;
  final ValueChanged<String> onSelected;
  final FormFieldValidator<String>? validator;

  const DialogSelectorField({
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
            final selected = await _showSelectorDialog(
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

  Future<String?> _showSelectorDialog(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String Function(String display) toValue,
    String? initiallySelectedValue,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                display,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF222222),
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check, color: Color(0xFF8B4513)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel / रद्द करें'),
                  ),
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


