import 'package:flutter/material.dart';
import '../constants/string_constants.dart';
import 'add_labour_work_screen.dart';

class WorkTypeSelectionScreen extends StatelessWidget {
  const WorkTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          StringConstants.getBilingual(StringConstants.selectWorkType, StringConstants.selectWorkTypeHindi),
          style: const TextStyle(
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
                    title: StringConstants.pathai,
                    titleHindi: StringConstants.pathaiHindi,
                    description: StringConstants.pathaiDescription,
                    descriptionHindi: StringConstants.pathaiDescriptionHindi,
                    icon: Icons.upload,
                    color: const Color(0xFF2196F3),
                    workType: StringConstants.pathai,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildWorkTypeCard(
                    context: context,
                    title: StringConstants.bharai,
                    titleHindi: StringConstants.bharaiHindi,
                    description: StringConstants.bharaiDescription,
                    descriptionHindi: StringConstants.bharaiDescriptionHindi,
                    icon: Icons.inventory,
                    color: const Color(0xFF4CAF50),
                    workType: StringConstants.bharai,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildWorkTypeCard(
                    context: context,
                    title: StringConstants.nikasi,
                    titleHindi: StringConstants.nikasiHindi,
                    description: StringConstants.nikasiDescription,
                    descriptionHindi: StringConstants.nikasiDescriptionHindi,
                    icon: Icons.download,
                    color: const Color(0xFFFF9800),
                    workType: StringConstants.nikasi,
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
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLabourWorkScreen(workType: workType),
            ),
          );
          
          // If work was saved successfully, return the result to the previous screen
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
