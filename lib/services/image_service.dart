import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload image binary data to Firebase Storage
  /// Returns download URL
  Future<String> uploadImage(
    Uint8List data,
    String folder, {
    String? fileName,
  }) async {
    try {
      final String name = fileName ?? '${_uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child(folder).child(name);

      // Determine content type roughly
      final metadata = SettableMetadata(
        contentType:
            'image/jpeg', // Default, browser often detects automatically or we can enhance
        customMetadata: {'uploaded_by': 'admin_app'},
      );

      final UploadTask uploadTask = ref.putData(data, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Delete image from URL
  Future<void> deleteImage(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore if file not found or other cleanup error
      print('Delete image error: $e');
    }
  }
}
