import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';

class TransactionTypeSelectionScreen extends StatelessWidget {
  const TransactionTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Select Transaction Type',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            Expanded(
              child: Column(
                children: [
                  _buildTransactionTypeCard(
                    context: context,
                    title: 'Salaries',
                    titleHindi: 'वेतन',
                    description: 'Payment for all employees',
                    descriptionHindi: 'सभी कर्मचारियों का भुगतान',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF2196F3),
                    transactionType: 'Salaries',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTransactionTypeCard(
                    context: context,
                    title: 'Sale',
                    titleHindi: 'बिक्री',
                    description: 'Sales transactions',
                    descriptionHindi: 'बिक्री लेनदेन',
                    icon: Icons.shopping_cart,
                    color: const Color(0xFF4CAF50),
                    transactionType: 'Sale',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTransactionTypeCard(
                    context: context,
                    title: 'Purchase',
                    titleHindi: 'खरीद',
                    description: 'Purchase transactions',
                    descriptionHindi: 'खरीद लेनदेन',
                    icon: Icons.shopping_bag,
                    color: const Color(0xFFFF9800),
                    transactionType: 'Purchase',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeCard({
    required BuildContext context,
    required String title,
    required String titleHindi,
    required String description,
    required String descriptionHindi,
    required IconData icon,
    required Color color,
    required String transactionType,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(transactionType: transactionType),
            ),
          );
          
          // If transaction was saved successfully, return the result to the previous screen
          if (result != null && context.mounted) {
            Navigator.pop(context, result);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titleHindi,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descriptionHindi,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

