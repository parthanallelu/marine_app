import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../providers/auth_provider.dart';

class ProfessorMaterialsScreen extends StatefulWidget {
  const ProfessorMaterialsScreen({super.key});

  @override
  State<ProfessorMaterialsScreen> createState() => _ProfessorMaterialsScreenState();
}

class _ProfessorMaterialsScreenState extends State<ProfessorMaterialsScreen> {
  List<StudyMaterialModel> _materials = [];
  bool _isLoading = true;
  
  // Controllers for upload form
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadMaterials() {
    // TODO: Replace with Firestore query in next phase:
    // materialRepository.getProfessorMaterials(professorId);
    
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel?;
    if (prof == null) return;

    // Simulate fetching materials uploaded by this professor
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

    // Reset controllers
    _titleController.clear();
    _descriptionController.clear();
    _selectedSubject = prof.subjects.isNotEmpty ? prof.subjects.first : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Study Material', style: AppTextStyles.headingSmall),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Title',
                hintText: 'e.g. Navigation Lesson 1',
                controller: _titleController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Description',
                hintText: 'Briefly describe the content',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Text('Subject', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: prof.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setModalState(() => _selectedSubject = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Confirm Upload',
                  onPressed: () => _handleUpload(prof),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUpload(ProfessorModel prof) {
    // Validation rules
    if (_titleController.text.trim().isEmpty) {
      _showError('Title is required');
      return;
    }
    if (_selectedSubject == null) {
      _showError('Subject is required');
      return;
    }

    // Mock local add
    setState(() {
      _materials.insert(0, StudyMaterialModel(
        id: 'mat_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        fileUrl: 'mock_url',
        fileType: FileType.pdf,
        category: _selectedSubject!,
        subject: _selectedSubject!,
        uploadedByProfessorId: prof.id,
        uploaderName: prof.name,
        uploadedAt: DateTime.now(),
        targetCourses: ['11th Science'],
      ));
    });
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Material uploaded successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Role security check
    if (!authProvider.isProfessor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.roleSelection);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
