import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class StudentMaterialsScreen extends StatefulWidget {
  const StudentMaterialsScreen({super.key});

  @override
  State<StudentMaterialsScreen> createState() => _StudentMaterialsScreenState();
}

class _StudentMaterialsScreenState extends State<StudentMaterialsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<StudyMaterialModel> _getFilteredMaterials() {
    return DummyData.materials.where((m) {
      final categoryMatch = _selectedCategory == 'All' || m.category == _selectedCategory;
      final queryMatch = _searchQuery.isEmpty || 
          m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return categoryMatch && queryMatch;
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'IMU-CET':
        return AppColors.navyBlueBase;
      case 'Psychometric':
        return AppColors.course12th;
      case 'English Communication':
        return AppColors.oceanBlue;
      case 'Maritime GK':
        return AppColors.courseCrash;
      case 'Interview Prep':
        return AppColors.gold;
      default:
        return AppColors.navyBlueBase;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMaterials = _getFilteredMaterials();
    final categories = ['All'] + AppConstants.materialCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavyHeader(
            title: "Study Materials",
            subtitle: "${DummyData.materials.length} resources available",
          ),
          
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search by title or category...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      }) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Horizontal category filter
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = category);
                    },
                    selectedColor: AppColors.navyBlueBase,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.navyBlueBase,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.navyBlueBase : AppColors.navyBlueSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: filteredMaterials.isEmpty
                ? const EmptyState(
                    icon: Icons.menu_book_rounded,
                    title: "No Materials Found",
                    subtitle: "Try adjusting your filters or search query.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredMaterials.length,
                    itemBuilder: (context, index) {
                      final material = filteredMaterials[index];
                      final categoryColor = _getCategoryColor(material.category);
                      
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
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: categoryColor.withAlpha((0.1 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                material.fileType == FileType.pdf ? Icons.description_rounded : Icons.play_circle_rounded,
                                color: categoryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material.title,
                                    style: AppTextStyles.labelLarge,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          material.category,
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ),
                                      if (material.companyTarget != null) ...[
                                        const SizedBox(width: 6),
                                        Text("•", style: AppTextStyles.caption),
                                        const SizedBox(width: 6),
                                        Text(
                                          material.companyTarget!,
                                          style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${material.uploaderName} • ${material.fileSizeLabel}",
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Downloading: ${material.title}")),
                                );
                              },
                              icon: const Icon(Icons.file_download_outlined, color: AppColors.navyBlueBase),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
