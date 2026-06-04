import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/cloudinary_settings.dart';

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
  });
}

class CloudinaryService {
  Future<CloudinaryUploadResult> uploadImage({
    required CloudinarySettings settings,
    required XFile file,
  }) async {
    if (!settings.isConfigured) {
      throw Exception('Cloudinary settings are not configured.');
    }

    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/${settings.cloudName.trim()}/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = settings.uploadPreset.trim();

    final folder = settings.folder.trim();
    if (folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }

    final bytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: file.name),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cloudinary upload failed: $body');
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = decoded['secure_url']?.toString() ?? '';
    if (secureUrl.isEmpty) {
      throw Exception('Cloudinary upload did not return an image URL.');
    }

    return CloudinaryUploadResult(
      secureUrl: secureUrl,
      publicId: decoded['public_id']?.toString() ?? '',
    );
  }
}
