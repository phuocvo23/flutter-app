import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:super_clipboard/super_clipboard.dart';
// import 'package:cross_file/cross_file.dart';
import '../../services/image_service.dart';

class AdminImagePicker extends StatefulWidget {
  final String? initialUrl;
  final Function(String url) onImageChanged;
  final String folder; // 'products' or 'categories'

  const AdminImagePicker({
    super.key,
    this.initialUrl,
    required this.onImageChanged,
    this.folder = 'products',
  });

  @override
  State<AdminImagePicker> createState() => _AdminImagePickerState();
}

class _AdminImagePickerState extends State<AdminImagePicker> {
  final ImageService _imageService = ImageService();
  String? _imageUrl;
  bool _isUploading = false;
  bool _isDragging = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialUrl;
  }

  @override
  void didUpdateWidget(AdminImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUrl != oldWidget.initialUrl) {
      _imageUrl = widget.initialUrl;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _uploadData(Uint8List data, String fileName) async {
    setState(() => _isUploading = true);
    try {
      final url = await _imageService.uploadImage(
        data,
        widget.folder,
        fileName: fileName,
      );
      setState(() {
        _imageUrl = url;
        _isUploading = false;
      });
      widget.onImageChanged(url);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Needed for web
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        await _uploadData(file.bytes!, file.name);
      }
    }
    _focusNode.requestFocus();
  }

  Future<void> _handlePaste() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final reader = await clipboard.read();

    if (reader.canProvide(Formats.png)) {
      reader.getFile(Formats.png, (file) async {
        final bytes = await file.readAll();
        _uploadData(
          bytes,
          'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png',
        );
      });
    } else if (reader.canProvide(Formats.jpeg)) {
      reader.getFile(Formats.jpeg, (file) async {
        final bytes = await file.readAll();
        _uploadData(
          bytes,
          'pasted_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image in clipboard')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect Ctrl+V
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyV, control: true): _handlePaste,
        SingleActivator(LogicalKeyboardKey.keyV, meta: true):
            _handlePaste, // Cmd+V on Mac
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: DropTarget(
          onDragEntered: (_) => setState(() => _isDragging = true),
          onDragExited: (_) => setState(() => _isDragging = false),
          onDragDone: (details) async {
            setState(() => _isDragging = false);
            if (details.files.isNotEmpty) {
              final file = details.files.first;
              final bytes = await file.readAsBytes();
              await _uploadData(bytes, file.name);
            }
          },
          child: GestureDetector(
            onTap: _pickFile, // Tap to pick
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    _isDragging
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isDragging ? Colors.blue : Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_imageUrl != null && !_isUploading)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder:
                            (_, __, ___) => const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Invalid Image URL',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                      ),
                    )
                  else if (!_isUploading)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: _isDragging ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isDragging
                              ? 'Drop image here'
                              : 'Click, Paste (Ctrl+V) or Drop Image',
                          style: TextStyle(
                            color: _isDragging ? Colors.blue : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  if (_isUploading)
                    const Center(child: CircularProgressIndicator()),

                  // Reset button if image exists
                  if (_imageUrl != null && !_isUploading)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          hoverColor: Colors.red,
                        ),
                        onPressed: () {
                          setState(() => _imageUrl = null);
                          widget.onImageChanged('');
                          // Optional: Delete from storage? Maybe not immediately to avoid accidental loss if they cancel edit.
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
