import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

/// Model for custom audio file
class CustomAudioFile {
  final String path;
  final String name;
  final String fileName;

  CustomAudioFile({
    required this.path,
    required this.name,
    required this.fileName,
  });
}

/// Service for managing custom audio files
class CustomAudioService {
  static const String _customAudioDir = 'custom_alarms';
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  /// Get the custom audio directory
  static Future<Directory> getCustomAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final customDir = Directory('${appDir.path}/$_customAudioDir');
    
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
    
    return customDir;
  }

  /// Pick audio file from device and save to app directory
  /// On web: Returns the file name only (files stored in memory)
  /// On mobile/desktop: Returns the full file path after copying to app storage
  static Future<String?> pickAndSaveAudio(String displayName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      // On web, we can't save to file system, so just return a reference
      if (kIsWeb) {
        final fileName = result.files.single.name;
        return 'web_$displayName:$fileName';
      }

      final sourceFile = File(result.files.single.path!);
      
      if (!await sourceFile.exists()) {
        return null;
      }
      
      final fileSize = await sourceFile.length();
      if (fileSize > _maxFileSizeBytes) {
        return null; // File too large
      }

      final customDir = await getCustomAudioDirectory();
      final extension = result.files.single.extension ?? 'mp3';
      final fileName = '${displayName}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final savedFile = File('${customDir.path}/$fileName');

      await sourceFile.copy(savedFile.path);
      return savedFile.path;
    } catch (_) {
      return null;
    }
  }

  /// Get list of all custom audio files
  static Future<List<CustomAudioFile>> getCustomAudioFiles() async {
    try {
      // Web platform doesn't support file system operations
      if (kIsWeb) {
        return [];
      }
      
      final customDir = await getCustomAudioDirectory();
      
      if (!await customDir.exists()) {
        return [];
      }
      
      final files = customDir.listSync().whereType<File>().toList();
      
      return files.map((file) {
        final fileName = file.path.split('/').last;
        final displayName = _extractFileName(fileName);
        return CustomAudioFile(
          path: file.path,
          name: displayName,
          fileName: fileName,
        );
      }).toList();
    } catch (e) {
      // Silently return empty list on any error (file not found, permissions, etc.)
      return [];
    }
  }

  /// Delete custom audio file
  static Future<bool> deleteCustomAudio(String filePath) async {
    try {
      // File operations not supported on web
      if (kIsWeb) {
        return false;
      }
      
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Extract display name from filename (removes timestamp suffix)
  static String _extractFileName(String fileName) {
    try {
      final withoutExtension = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
      final parts = withoutExtension.split('_');
      
      // Remove timestamp (last part is usually timestamp)
      if (parts.length > 1) {
        parts.removeLast();
        return parts.join('_').replaceAll('_', ' ').toUpperCase().replaceRange(0, 1, fileName[0]);
      }
      
      return withoutExtension;
    } catch (_) {
      return fileName;
    }
  }
}
