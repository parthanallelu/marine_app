import 'dart:io';

/// Abstract interface for file storage operations.
abstract class StorageService {
  /// Uploads a file and returns the download URL.
  Future<String> uploadFile(String path, File file);

  /// Deletes a file at the specified path.
  Future<void> deleteFile(String path);

  /// Gets the download URL for a file.
  Future<String> getDownloadUrl(String path);
}
