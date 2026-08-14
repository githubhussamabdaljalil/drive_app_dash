import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

class FileDownloadHelper {
  static void downloadPdf(
    Uint8List bytes, {
    String fileName = 'owner_reports.pdf',
  }) {
    final blob = html.Blob(
      [bytes],
      'application/pdf',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}