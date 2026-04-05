import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class ProfessorMaterialsScreen extends StatefulWidget {
  const ProfessorMaterialsScreen({super.key});

  @override
  State<ProfessorMaterialsScreen> createState() => _ProfessorMaterialsScreenState();
}

class _ProfessorMaterialsScreenState extends State<ProfessorMaterialsScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final professor = context.watch<AuthProvider>().currentUser as ProfessorModel;
    
    // Filter materials created by this professor
    final materials = DummyData.materials.where((m) {
      final matchesProfessor = m.uploadedByProfessorId == professor.id;
      final matchesCategory = _selectedCategory == "All" || m.category == _selectedCategory;
      final matchesSearch = m.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesProfessor && matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Study Materials", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
        actions: [
          IconButton(
            onPressed: () => _showUploadDialog(),
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.navyBlueBase),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // SEARCH & FILTER BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: Colors.white,
            child: Column(
              children: [
                CustomTextField(
                  hintText: "Search your uploads...",
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: "All",
                        isSelected: _selectedCategory == "All",
                        onTap: () => setState(() => _selectedCategory = "All"),
                      ),
                      ...AppConstants.materialCategories.map((cat) => _CategoryChip(
                            label: cat,
                            isSelected: _selectedCategory == cat,
                            onTap: () => setState(() => _selectedCategory = cat),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MATERIALS LIST
          Expanded(
            child: materials.isEmpty
                ? const EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: "No Materials Found",
                    subtitle: "You haven't uploaded any materials in this category yet.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final material = materials[index];
                      return _MaterialUploadTile(material: material);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(),
        label: const Text("Upload New"),
        icon: const Icon(Icons.upload_file_rounded),
        backgroundColor: AppColors.navyBlueBase,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upload Study Material", style: AppTextStyles.headingMedium),
              const SizedBox(height: 20),
              const CustomTextField(label: "Title", hintText: "e.g. Navigation Basics PDF"),
              const SizedBox(height: 16),
              const CustomTextField(label: "Description", hintText: "Enter a short description", maxLines: 3),
              const SizedBox(height: 16),
              Text("Category", style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              // Dummy Dropdown Placeholder
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: AppRadius.inputRadius,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Select Category"),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: "CANCEL",
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      label: "UPLOAD",
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Material uploaded successfully!")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyBlueBase : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.navyBlueBase : AppColors.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialUploadTile extends StatelessWidget {
  final StudyMaterialModel material;
  const _MaterialUploadTile({required this.material});

  @override
  Widget build(BuildContext context) {
    final isPdf = material.fileType == FileType.pdf;
    final iconColor = isPdf ? const Color(0xFFC62828) : AppColors.oceanBlue;
    final icon = isPdf ? Icons.picture_as_pdf_rounded : Icons.play_circle_fill_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.title, style: AppTextStyles.labelLarge),
                Text(
                  "${material.category} • ${material.uploadedAt.toString().split(' ')[0]}",
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
