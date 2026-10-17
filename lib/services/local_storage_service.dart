import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  static const String indexName =
      'gallery_index.json';

  static Future<Directory> appDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  static Future<File> indexFile() async {
    final directory =
        await appDirectory();

    return File(
      '${directory.path}/$indexName',
    );
  }

  static Future<List<Map<String, dynamic>>>
      readIndex() async {
    try {
      final file = await indexFile();

      if (!await file.exists()) {
        return [];
      }

      final content =
          await file.readAsString();

      if (content.trim().isEmpty) {
        return [];
      }

      final decoded =
          jsonDecode(content);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (item) =>
                Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> writeIndex(
    List<Map<String, dynamic>> data,
  ) async {
    final file = await indexFile();

    await file.writeAsString(
      jsonEncode(data),
    );
  }
}