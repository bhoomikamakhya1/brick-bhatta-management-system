import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Transaction Details / लेन-देन विवरण',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Amount
            _buildHeaderCard(),

            const SizedBox(height: 16),

            // Transaction Information
            _buildInfoSection(
              title: 'Transaction Information / लेन-देन की जानकारी',
              children: [
                _buildReadonlyField('Party Name / पार्टी का नाम', transaction.englishName),
                if (transaction.hindiName != transaction.englishName)
                  _buildReadonlyField('हिंदी नाम', transaction.hindiName),
                _buildReadonlyField('Category / श्रेणी', transaction.category),
                _buildReadonlyField('Date / तारीख', transaction.date),
                _buildReadonlyField(
                  'Type / प्रकार',
                  transaction.type == TransactionType.credit ? 'Credit / क्रेडिट' : 'Debit / डेबिट',
                  valueColor: transaction.type == TransactionType.credit
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                ),
                if (transaction.description != null && transaction.description!.isNotEmpty)
                  _buildReadonlyField('Description / विवरण', transaction.description!),
              ],
            ),

            const SizedBox(height: 16),

            // Transaction ID (if available)
            if (transaction.id != null)
              _buildInfoSection(
                title: 'System Information / सिस्टम जानकारी',
                children: [
                  _buildReadonlyField('Transaction ID', transaction.id!),
                  if (transaction.partyId != null)
                    _buildReadonlyField('Party ID', transaction.partyId!),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: transaction.type == TransactionType.credit
                ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                : [const Color(0xFFF44336), const Color(0xFFEF5350)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              transaction.type == TransactionType.credit ? 'CREDIT' : 'DEBIT',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${transaction.amount?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.englishName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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

  Widget _buildReadonlyField(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
