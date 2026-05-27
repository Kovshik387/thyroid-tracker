import 'dart:typed_data';

import 'package:printing/printing.dart';

Future<void> savePdfFile({
  required Uint8List bytes,
  required String fileName,
}) {
  return Printing.layoutPdf(
    name: fileName,
    onLayout: (_) async => bytes,
  );
}
