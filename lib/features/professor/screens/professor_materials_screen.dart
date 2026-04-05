import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../providers/auth_provider.dart';

class ProfessorMaterialsScreen extends StatefulWidget {
  const ProfessorMaterialsScreen({super.key});

  @override
  State<ProfessorMaterialsScreen> createState() => _ProfessorMaterialsScreenState();
}

class _ProfessorMaterialsScreenState extends State<ProfessorMaterialsScreen> {
  List<StudyMaterialModel> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  void _loadMaterials() {
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel?;
    if (prof == null) return;

    // Simulate fetching materials uploaded by this professor
    // Since DummyData doesn't have a static list, we mock it here
    setState(() {
      _materials = [
        StudyMaterialModel(
          id: 'mat_001',
          title: 'IMU-CET Navigation Basics',
          description: 'Introduction to celestial navigation for deck cadets.',
          fileUrl: 'https://example.com/nav_basics.pdf',
          fileType: FileType.pdf,
          category: 'IMU-CET',
          subject: 'IMU-CET',
          uploadedByProfessorId: prof.id,
          uploaderName: prof.name,
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          targetCourses: ['11th Science', '12th Science'],
        ),
        StudyMaterialModel(
          id: 'mat_002',
          title: 'Maritime GK Monthly Capsule',
          description: 'Important maritime current affairs for March 2024.',
          fileUrl: 'https://example.com/gk_capsule.pdf',
          fileType: FileType.pdf,
          category: 'Maritime GK',
          subject: 'Maritime GK',
          uploadedByProfessorId: prof.id,
          uploaderName: prof.name,
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          targetCourses: ['12th Science'],
        ),
      ];
      _isLoading = false;
    });
  }

  void _deleteMaterial(String id) {
    setState(() {
      _materials.removeWhere((m) => m.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material deleted successfully')),
    );
  }

  void _showUploadBottomSheet() {
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel?;
    if (prof == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Study Material', style: AppTextStyles.headingSmall),
            const SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Subject', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: prof.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Confirm Upload',
                onPressed: () {
                  // Mock local add
                  setState(() {
                    _materials.insert(0, StudyMaterialModel(
                      id: 'mat_${DateTime.now().millisecondsSinceEpoch}',
                      title: 'New Uploaded Material',
                      description: 'Freshly uploaded content.',
                      fileUrl: '',
                      fileType: FileType.pdf,
                      category: prof.subjects.first,
                      subject: prof.subjects.first,
                      uploadedByProfessorId: prof.id,
                      uploaderName: prof.name,
                      uploadedAt: DateTime.now(),
                      targetCourses: ['11th Science'],
                    ));
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Study Materials', style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.navyBlueBase,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materials.isEmpty
              ? const EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'No Materials',
                  subtitle: 'Upload your first study material to get started.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: DashboardCard(
                        title: material.title,
                        subtitle: material.subject,
                        leading: Icon(
                          material.fileType == FileType.pdf ? Icons.picture_as_pdf_rounded : Icons.link_rounded,
                          color: AppColors.navyBlueBase,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _deleteMaterial(material.id),
                        ),
                        onTap: () {
                          // Logic to view/download material
                        },
                        child: Text(
                          material.description,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadBottomSheet,
        backgroundColor: AppColors.navyBlueBase,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
