import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class StudentMaterialsScreen extends StatefulWidget {
  const StudentMaterialsScreen({super.key});

  @override
  State<StudentMaterialsScreen> createState() => _StudentMaterialsScreenState();
}

class _StudentMaterialsScreenState extends State<StudentMaterialsScreen> {
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late List<StudyMaterialModel> _allMaterials;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  void _loadMaterials() {
    setState(() => _isLoading = true);
    
    // TODO: Replace DummyData with Firestore query:
    // _allMaterials = await materialRepository.getAllMaterials();
    _allMaterials = DummyData.materials;

    setState(() => _isLoading = false);
  }

  List<StudyMaterialModel> _getFilteredMaterials() {
    return _allMaterials.where((m) {
      final categoryMatch = _selectedCategory == 'All' || m.category == _selectedCategory;
      final queryMatch = _searchQuery.isEmpty || 
          m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return categoryMatch && queryMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Access Control Safety
    if (!authProvider.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredMaterials = _getFilteredMaterials();
    final categories = ['All'] + AppConstants.materialCategories;

    return AppPageShell(
      title: "Study Materials",
      subtitle: "${_allMaterials.length} resources available",
      showBackButton: false,
      headerWidgets: [
        CustomTextField(
          controller: _searchController,
          hintText: "Search by title or category...",
          prefixIcon: Icons.search_rounded,
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                  selectedColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.navyBlueBase : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white.withAlpha((0.15 * 255).round()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    side: BorderSide(
                      color: isSelected ? Colors.white : Colors.white24,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
      ],
      body: filteredMaterials.isEmpty
          ? const Column(
              children: [
                SizedBox(height: 100),
                EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: "No Materials Found",
                  subtitle: "Try adjusting your filters or search query.",
                ),
              ],
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: filteredMaterials.length,
              itemBuilder: (context, index) {
                final material = filteredMaterials[index];
                return MaterialCard(
                  material: material,
                  onDownload: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Downloading: ${material.title}")),
                    );
                  },
                );
              },
            ),
    );
  }
}
