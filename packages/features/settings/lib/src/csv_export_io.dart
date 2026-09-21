import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadCsv(String content, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    subject: filename,
  );
}
