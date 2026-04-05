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
        context.goNamed('role_selection');
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavyHeader(
            title: "Study Materials",
            subtitle: "${_allMaterials.length} resources available",
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

          // LIST PERFORMANCE: Using ListView.builder for dynamic lists
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
                      // REUSABLE COMPONENT: Using MaterialCard
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
          ),
        ],
      ),
    );
  }
}
