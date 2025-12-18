// Web implementation for CSV operations
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';

/// Download CSV on web (triggers browser download)
void downloadCsv(String csvContent, String filename) {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor =
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..style.display = 'none';

  html.document.body!.children.add(anchor);
  anchor.click();

  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

/// Pick and read CSV file on web
Future<String?> pickAndReadCsvFile() async {
  final completer = Completer<String?>();

  final input = html.FileUploadInputElement()..accept = '.csv';

  // Add to DOM temporarily
  input.style.display = 'none';
  html.document.body!.children.add(input);

  input.onChange.listen((event) async {
    try {
      if (input.files == null || input.files!.isEmpty) {
        completer.complete(null);
        return;
      }

      final file = input.files!.first;
      final reader = html.FileReader();

      reader.onLoad.listen((event) {
        final result = reader.result as String?;
        completer.complete(result);
      });

      reader.onError.listen((event) {
        print('FileReader error: ${reader.error}');
        completer.complete(null);
      });

      reader.readAsText(file);
    } catch (e) {
      print('Error reading file: $e');
      completer.complete(null);
    } finally {
      // Remove from DOM
      html.document.body!.children.remove(input);
    }
  });

  // Handle cancel (no file selected)
  input.onAbort.listen((_) {
    html.document.body!.children.remove(input);
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  });

  // Trigger file picker
  input.click();

  return completer.future;
}
