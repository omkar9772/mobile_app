import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import '../config/app_config.dart';

class ImageCompressionHelper {
  /// Compress image before upload
  /// Validates file size and compresses to specified dimensions and quality
  static Future<File> compressImage(File file) async {
    // Get file size
    final bytes = await file.length();

    // Validate file size
    if (bytes > AppConfig.maxImageSize) {
      throw Exception('Image too large. Maximum size is 5MB.');
    }

    // If image is already small enough, skip compression
    if (bytes < 500 * 1024) {
      // Less than 500KB, no need to compress
      return file;
    }

    try {
      // Generate output path
      final dir = file.parent;
      final fileName = path.basenameWithoutExtension(file.path);
      final ext = path.extension(file.path);
      final outputPath = path.join(dir.path, '${fileName}_compressed$ext');

      // Compress the image
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outputPath,
        quality: AppConfig.imageQuality,
        minWidth: AppConfig.maxImageDimension,
        minHeight: AppConfig.maxImageDimension,
        format: CompressFormat.jpeg, // Always convert to JPEG for consistency
      );

      if (result == null) {
        throw Exception('Image compression failed. Please try again.');
      }

      return File(result.path);
    } catch (e) {
      // If compression fails, return original file
      // (Better to upload uncompressed than fail completely)
      return file;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Validate image file
  static Future<bool> validateImage(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Check file size
      final bytes = await file.length();
      if (bytes > AppConfig.maxImageSize) {
        return false;
      }

      // Check file extension
      final ext = path.extension(file.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
