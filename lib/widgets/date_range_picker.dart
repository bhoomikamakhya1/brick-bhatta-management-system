import 'package:flutter/material.dart';

class DateRangePicker extends StatelessWidget {
  final String label;
  final String labelHindi;
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback? onFromDateTap;
  final VoidCallback? onToDateTap;

  const DateRangePicker({
    super.key,
    required this.label,
    required this.labelHindi,
    this.fromDate,
    this.toDate,
    this.onFromDateTap,
    this.onToDateTap,
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
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onFromDateTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fromDate != null 
                                  ? '${fromDate!.day.toString().padLeft(2, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.year}'
                                  : 'dd-mm-yyyy',
                              style: TextStyle(
                                fontSize: 14,
                                color: fromDate != null ? const Color(0xFF333333) : Colors.grey[500],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'From / से',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onToDateTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              toDate != null 
                                  ? '${toDate!.day.toString().padLeft(2, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.year}'
                                  : 'dd-mm-yyyy',
                              style: TextStyle(
                                fontSize: 14,
                                color: toDate != null ? const Color(0xFF333333) : Colors.grey[500],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'To / तक',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
