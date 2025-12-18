// Stub implementation for non-web platforms (mobile/desktop)
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Download CSV (saves to file on non-web)
void downloadCsv(String csvContent, String filename) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(csvContent);
    print('CSV saved to: ${file.path}');
  } catch (e) {
    print('Error saving CSV: $e');
  }
}

/// Pick and read CSV file
Future<String?> pickAndReadCsvFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.single.path!);
    return await file.readAsString();
  } catch (e) {
    print('Error picking CSV: $e');
    return null;
  }
}
