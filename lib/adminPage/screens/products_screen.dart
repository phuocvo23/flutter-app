import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/admin_theme.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/csv_service.dart';
import '../../models/category.dart';

/// Products Management Screen
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final CsvService _csvService = CsvService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Products',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.textPrimary,
                ),
              ),
              const Spacer(),
              // Export CSV
              OutlinedButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export CSV'),
              ),
              const SizedBox(width: 8),
              // Import CSV
              OutlinedButton.icon(
                onPressed: _importCsv,
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Import CSV'),
              ),
              const SizedBox(width: 8),
              // Add Product
              ElevatedButton.icon(
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24),

          // Products Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: StreamBuilder<List<Product>>(
                stream: _productService.getAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  final products =
                      snapshot.data!
                          .where(
                            (p) => p.name.toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ),
                          )
                          .toList();

                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('Rating')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows:
                          products
                              .map((product) => _buildProductRow(product))
                              .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildProductRow(Product product) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: AdminTheme.card,
                        child: const Icon(
                          Icons.image,
                          color: AdminTheme.textSecondary,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  product.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(product.category)),
        DataCell(Text('₫${NumberFormat('#,###').format(product.price)}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  product.stock > 10
                      ? AdminTheme.success.withOpacity(0.1)
                      : AdminTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${product.stock}',
              style: TextStyle(
                color:
                    product.stock > 10
                        ? AdminTheme.success
                        : AdminTheme.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.star, color: AdminTheme.warning, size: 16),
              const SizedBox(width: 4),
              Text(product.rating.toStringAsFixed(1)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AdminTheme.info),
                onPressed: () => _showEditProductDialog(product),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AdminTheme.error),
                onPressed: () => _deleteProduct(product),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddProductDialog() {
    _showProductDialog(null);
  }

  void _showEditProductDialog(Product product) {
    _showProductDialog(product);
  }

  void _showProductDialog(Product? product) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final originalPriceController = TextEditingController(
      text: product?.originalPrice?.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    final imageUrlController = TextEditingController(
      text: product?.imageUrl ?? '',
    );
    String? selectedCategory = product?.category;
    bool isFeatured = product?.isFeatured ?? false;
    bool isNew = product?.isNew ?? false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: AdminTheme.surface,
                  title: Text(isEditing ? 'Edit Product' : 'Add Product'),
                  content: SizedBox(
                    width: 500,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<Category>>(
                            stream: _categoryService.getAll(),
                            builder: (context, snapshot) {
                              final categories = snapshot.data ?? [];
                              // Kiểm tra nếu selectedCategory không có trong list thì set null
                              final categoryNames =
                                  categories.map((c) => c.name).toList();
                              if (selectedCategory != null &&
                                  !categoryNames.contains(selectedCategory)) {
                                selectedCategory = null;
                              }
                              return DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                hint: const Text('Select category'),
                                items:
                                    categories
                                        .map(
                                          (cat) => DropdownMenuItem(
                                            value: cat.name,
                                            child: Text(cat.name),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(
                                      () => selectedCategory = value,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: originalPriceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Original Price',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: isFeatured,
                                onChanged:
                                    (value) => setDialogState(
                                      () => isFeatured = value ?? false,
                                    ),
                              ),
                              const Text('Featured'),
                              const SizedBox(width: 24),
                              Checkbox(
                                value: isNew,
                                onChanged:
                                    (value) => setDialogState(
                                      () => isNew = value ?? false,
                                    ),
                              ),
                              const Text('New'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            priceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill required fields'),
                            ),
                          );
                          return;
                        }

                        final newProduct = Product(
                          id:
                              product?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          description: descController.text,
                          imageUrl:
                              imageUrlController.text.isNotEmpty
                                  ? imageUrlController.text
                                  : 'https://via.placeholder.com/400',
                          category: selectedCategory ?? '',
                          price: double.tryParse(priceController.text) ?? 0,
                          originalPrice:
                              originalPriceController.text.isNotEmpty
                                  ? double.tryParse(
                                    originalPriceController.text,
                                  )
                                  : null,
                          stock: int.tryParse(stockController.text) ?? 0,
                          isFeatured: isFeatured,
                          isNew: isNew,
                          rating: product?.rating ?? 0,
                          reviewCount: product?.reviewCount ?? 0,
                          sizes: product?.sizes ?? [],
                          colors: product?.colors ?? [],
                          createdAt: product?.createdAt,
                        );

                        try {
                          if (isEditing) {
                            await _productService.update(newProduct);
                          } else {
                            await _productService.add(newProduct);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Product updated!'
                                    : 'Product added!',
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

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AdminTheme.surface,
            title: const Text('Delete Product'),
            content: Text('Are you sure you want to delete "${product.name}"?'),
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
                  await _productService.delete(product.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted!')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _exportCsv() async {
    try {
      final success = await _csvService.downloadProductsCsv();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  void _importCsv() async {
    try {
      final count = await _csvService.importProductsFromCsv();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Imported $count products!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }
}
