// Dart core
import 'dart:io';

// External packages
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:image_clipboard/image_clipboard.dart';

//downloadImageToTempFile
Future<File> downloadImageToTempFile(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to download image. Status code: ${response.statusCode}',
    );
  }

  final tempDir = await getTemporaryDirectory();
  final file = File(
    '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(response.bodyBytes);

  return file;
}

Future<void> copyImageToClipboard(File file) async {
  try {
    final imageClipboard = ImageClipboard();
    await imageClipboard.copyImage(file.path);
  } catch (e) {
    // ignore: avoid_print
    print('Error copying image to clipboard: $e');
  }
}
