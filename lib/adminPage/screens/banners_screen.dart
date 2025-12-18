import 'package:flutter/material.dart';
import '../config/admin_theme.dart';
import '../widgets/admin_image_picker.dart';
import '../../models/hero_banner.dart';
import '../../services/banner_service.dart';

/// Banners Management Screen
class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final BannerService _bannerService = BannerService();

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
                'Hero Banners',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddBannerDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Banner'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Quản lý banner hiển thị trên trang chủ. Kéo để sắp xếp thứ tự.',
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Banners List
          Expanded(
            child: StreamBuilder<List<HeroBanner>>(
              stream: _bannerService.getAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final banners = snapshot.data!;
                return ReorderableListView.builder(
                  itemCount: banners.length,
                  onReorder: (oldIndex, newIndex) {
                    _reorderBanners(banners, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    return _buildBannerCard(
                      banners[index],
                      key: ValueKey(banners[index].id),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_carousel_outlined,
            size: 80,
            color: AdminTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có banner nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm banner để hiển thị trên trang chủ',
            style: TextStyle(color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(HeroBanner banner, {Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      color: AdminTheme.surface,
      child: Row(
        children: [
          // Drag handle
          Container(
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.drag_handle,
              color: AdminTheme.textSecondary,
            ),
          ),
          // Preview image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              banner.imageUrl,
              width: 160,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 160,
                    height: 90,
                    color: AdminTheme.card,
                    child: const Icon(
                      Icons.image,
                      color: AdminTheme.textSecondary,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  style: const TextStyle(
                    color: AdminTheme.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            banner.isActive
                                ? AdminTheme.success.withOpacity(0.1)
                                : AdminTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        banner.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color:
                              banner.isActive
                                  ? AdminTheme.success
                                  : AdminTheme.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order: ${banner.order}',
                      style: const TextStyle(
                        color: AdminTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              Switch(
                value: banner.isActive,
                onChanged: (value) {
                  _bannerService.toggleActive(banner.id, value);
                },
                activeColor: AdminTheme.primary,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AdminTheme.info),
                onPressed: () => _showEditBannerDialog(banner),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AdminTheme.error),
                onPressed: () => _deleteBanner(banner),
                tooltip: 'Delete',
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  void _reorderBanners(List<HeroBanner> banners, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;

    // Update order in Firestore
    for (int i = 0; i < banners.length; i++) {
      int newOrder = i;
      if (i == oldIndex) {
        newOrder = newIndex;
      } else if (oldIndex < newIndex && i > oldIndex && i <= newIndex) {
        newOrder = i - 1;
      } else if (oldIndex > newIndex && i >= newIndex && i < oldIndex) {
        newOrder = i + 1;
      }

      if (newOrder != banners[i].order) {
        _bannerService.updateOrder(banners[i].id, newOrder);
      }
    }
  }

  void _showAddBannerDialog() {
    _showBannerDialog(null);
  }

  void _showEditBannerDialog(HeroBanner banner) {
    _showBannerDialog(banner);
  }

  void _showBannerDialog(HeroBanner? banner) {
    final isEditing = banner != null;
    final titleController = TextEditingController(text: banner?.title ?? '');
    final subtitleController = TextEditingController(
      text: banner?.subtitle ?? '',
    );
    final buttonTextController = TextEditingController(
      text: banner?.buttonText ?? 'Xem ngay',
    );
    final imageUrlController = TextEditingController(
      text: banner?.imageUrl ?? '',
    );
    String? selectedLinkType = banner?.linkType;
    final linkValueController = TextEditingController(
      text: banner?.linkValue ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: AdminTheme.surface,
                  title: Text(isEditing ? 'Edit Banner' : 'Add Banner'),
                  content: SizedBox(
                    width: 600,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image URL TextField
                          TextField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'Paste image URL or use picker below',
                              prefixIcon: Icon(Icons.link),
                            ),
                            onChanged: (value) => setDialogState(() {}),
                          ),
                          const SizedBox(height: 16),

                          // OR Upload with Picker
                          const Text(
                            'Or upload image:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AdminTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AdminImagePicker(
                            initialUrl: imageUrlController.text,
                            folder: 'banners',
                            onImageChanged: (url) {
                              imageUrlController.text = url;
                              setDialogState(() {});
                            },
                          ),
                          const SizedBox(height: 16),

                          // Title
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              hintText: 'e.g. Summer Sale',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          TextField(
                            controller: subtitleController,
                            decoration: const InputDecoration(
                              labelText: 'Subtitle',
                              hintText: 'e.g. Up to 50% off on all items',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),

                          // Button Text
                          TextField(
                            controller: buttonTextController,
                            decoration: const InputDecoration(
                              labelText: 'Button Text',
                              hintText: 'e.g. Shop Now',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Link Type
                          DropdownButtonFormField<String>(
                            value: selectedLinkType,
                            decoration: const InputDecoration(
                              labelText: 'Link Type (Optional)',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('None'),
                              ),
                              DropdownMenuItem(
                                value: 'category',
                                child: Text('Category'),
                              ),
                              DropdownMenuItem(
                                value: 'product',
                                child: Text('Product'),
                              ),
                              DropdownMenuItem(
                                value: 'url',
                                child: Text('External URL'),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() => selectedLinkType = value);
                            },
                          ),

                          if (selectedLinkType != null) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: linkValueController,
                              decoration: InputDecoration(
                                labelText:
                                    selectedLinkType == 'category'
                                        ? 'Category ID'
                                        : selectedLinkType == 'product'
                                        ? 'Product ID'
                                        : 'URL',
                                hintText:
                                    selectedLinkType == 'url'
                                        ? 'https://example.com'
                                        : 'Enter ID',
                              ),
                            ),
                          ],
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
                        if (titleController.text.isEmpty ||
                            imageUrlController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in title and image'),
                            ),
                          );
                          return;
                        }

                        final newBanner = HeroBanner(
                          id: banner?.id ?? '',
                          title: titleController.text,
                          subtitle: subtitleController.text,
                          imageUrl: imageUrlController.text,
                          buttonText:
                              buttonTextController.text.isNotEmpty
                                  ? buttonTextController.text
                                  : 'Xem ngay',
                          linkType: selectedLinkType,
                          linkValue:
                              linkValueController.text.isNotEmpty
                                  ? linkValueController.text
                                  : null,
                          isActive: banner?.isActive ?? true,
                          order: banner?.order ?? 999,
                        );

                        try {
                          if (isEditing) {
                            await _bannerService.update(newBanner);
                          } else {
                            await _bannerService.add(newBanner);
                          }
                          if (mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing ? 'Banner updated!' : 'Banner added!',
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

  void _deleteBanner(HeroBanner banner) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AdminTheme.surface,
            title: const Text('Delete Banner'),
            content: Text('Are you sure you want to delete "${banner.title}"?'),
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
                  await _bannerService.delete(banner.id);
                  if (mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Banner deleted!')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
