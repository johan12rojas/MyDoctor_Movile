import 'dart:convert';
import 'dart:typed_data';

Uint8List? decodeBase64Image(String? data) {
  if (data == null || data.isEmpty) return null;
  try {
    final sanitized = data.contains(',')
        ? data.substring(data.indexOf(',') + 1)
        : data;
    return base64Decode(sanitized);
  } catch (_) {
    return null;
  }
}

