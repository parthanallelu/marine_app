/// Generic interface for database operations.
abstract class FirestoreService {
  /// Fetches a single document by ID.
  Future<Map<String, dynamic>?> getDocument(String collectionPath, String documentId);

  /// Streams a single document by ID.
  Stream<Map<String, dynamic>?> streamDocument(String collectionPath, String documentId);

  /// Streams a collection with optional filtering.
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collectionPath, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
  });

  /// Adds a new document to a collection.
  Future<String> addDocument(String collectionPath, Map<String, dynamic> data);

  /// Sets (creates or overwrites) a document by ID.
  Future<void> setDocument(String collectionPath, String documentId, Map<String, dynamic> data);

  /// Updates an existing document.
  Future<void> updateDocument(String collectionPath, String documentId, Map<String, dynamic> data);

  /// Deletes a document by ID.
  Future<void> deleteDocument(String collectionPath, String documentId);

  /// Performs a batch write.
  Future<void> batchWrite(List<Map<String, dynamic>> operations);
}
