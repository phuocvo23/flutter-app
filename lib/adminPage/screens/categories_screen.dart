import 'package:flutter/material.dart';
import '../config/admin_theme.dart';
import '../widgets/admin_image_picker.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

/// Categories Management Screen
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();

  // Icon mapping for selection
  static const Map<String, IconData> _iconMap = {
    'sports_motorsports': Icons.sports_motorsports,
    'back_hand': Icons.back_hand,
    'checkroom': Icons.checkroom,
    'shield': Icons.shield,
    'snowshoeing': Icons.snowshoeing,
    'backpack': Icons.backpack,
    'dry_cleaning': Icons.dry_cleaning,
    'settings_input_component': Icons.settings_input_component,
    'category': Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categories Grid
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: _categoryService.getAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found'));
                }

                final categories = snapshot.data!;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: categories.length,
                  itemBuilder:
                      (context, index) => _buildCategoryCard(categories[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AdminTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: AdminTheme.primary,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.productCount} products',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AdminTheme.textSecondary,
              ),
              color: AdminTheme.card,
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditCategoryDialog(category);
                } else if (value == 'delete') {
                  _deleteCategory(category);
                }
              },
              itemBuilder:
                  (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AdminTheme.error),
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog(null);
  }

  void _showEditCategoryDialog(Category category) {
    _showCategoryDialog(category);
  }

  void _showCategoryDialog(Category? category) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final imageUrlController = TextEditingController(
      text: category?.imageUrl ?? '',
    );
    String selectedIcon = category?.iconName ?? 'category';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: AdminTheme.surface,
                  title: Text(isEditing ? 'Edit Category' : 'Add Category'),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Image URL (Auto-filled by picker)',
                          ),
                          onChanged:
                              (value) =>
                                  setDialogState(() {}), // Update UI if needed
                        ),
                        const SizedBox(height: 16),
                        AdminImagePicker(
                          initialUrl: imageUrlController.text,
                          folder: 'categories',
                          onImageChanged: (url) {
                            imageUrlController.text = url;
                            setDialogState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select Icon:',
                          style: TextStyle(color: AdminTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _iconMap.entries
                                  .map(
                                    (entry) => InkWell(
                                      onTap:
                                          () => setDialogState(
                                            () => selectedIcon = entry.key,
                                          ),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color:
                                              selectedIcon == entry.key
                                                  ? AdminTheme.primary
                                                      .withOpacity(0.2)
                                                  : AdminTheme.card,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border:
                                              selectedIcon == entry.key
                                                  ? Border.all(
                                                    color: AdminTheme.primary,
                                                    width: 2,
                                                  )
                                                  : null,
                                        ),
                                        child: Icon(
                                          entry.value,
                                          color:
                                              selectedIcon == entry.key
                                                  ? AdminTheme.primary
                                                  : AdminTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter category name'),
                            ),
                          );
                          return;
                        }

                        final newCategory = Category(
                          id:
                              category?.id ??
                              nameController.text.toLowerCase().replaceAll(
                                ' ',
                                '_',
                              ),
                          name: nameController.text,
                          iconName: selectedIcon,
                          imageUrl:
                              imageUrlController.text.isNotEmpty
                                  ? imageUrlController.text
                                  : 'https://via.placeholder.com/400',
                          productCount: category?.productCount ?? 0,
                        );

                        try {
                          if (isEditing) {
                            await _categoryService.update(newCategory);
                          } else {
                            await _categoryService.add(newCategory);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Category updated!'
                                    : 'Category added!',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AdminTheme.surface,
            title: const Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.error,
                ),
                onPressed: () async {
                  await _categoryService.delete(category.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category deleted!')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
