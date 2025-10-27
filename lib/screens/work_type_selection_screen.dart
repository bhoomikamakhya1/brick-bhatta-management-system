import 'package:flutter/material.dart';
import 'add_labour_work_screen.dart';

class WorkTypeSelectionScreen extends StatelessWidget {
  const WorkTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Select Work Type',
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
            
            // Header
            // const Text(
            //   'Choose Work Type',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Color(0xFF333333),
            //   ),
            // ),
            // const SizedBox(height: 8),
            // const Text(
            //   'Select the type of labour work you want to add',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Color(0xFF666666),
            //   ),
            // ),
            //
            // const SizedBox(height: 40),
            //
            // Work Type Options
            Expanded(
              child: Column(
                children: [
                  _buildWorkTypeCard(
                    context: context,
                    title: 'Pathai',
                    titleHindi: 'पठाई',
                    description: 'Loading and unloading work',
                    descriptionHindi: 'लोडिंग और अनलोडिंग का काम',
                    icon: Icons.upload,
                    color: const Color(0xFF2196F3),
                    workType: 'Pathai',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildWorkTypeCard(
                    context: context,
                    title: 'Bharai',
                    titleHindi: 'भराई',
                    description: 'Filling and packing work',
                    descriptionHindi: 'भराई और पैकिंग का काम',
                    icon: Icons.inventory,
                    color: const Color(0xFF4CAF50),
                    workType: 'Bharai',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildWorkTypeCard(
                    context: context,
                    title: 'Nikasi',
                    titleHindi: 'निकासी',
                    description: 'Unloading and distribution work',
                    descriptionHindi: 'अनलोडिंग और वितरण का काम',
                    icon: Icons.download,
                    color: const Color(0xFFFF9800),
                    workType: 'Nikasi',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkTypeCard({
    required BuildContext context,
    required String title,
    required String titleHindi,
    required String description,
    required String descriptionHindi,
    required IconData icon,
    required Color color,
    required String workType,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLabourWorkScreen(workType: workType),
            ),
          );
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
