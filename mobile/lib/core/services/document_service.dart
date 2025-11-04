import '../models/document_model.dart';

class DocumentService {
  final List<DocumentModel> _documents = [];

  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get all documents for a user
  Future<List<DocumentModel>> getDocuments(String userId) async {
    await _mockDelay();
    return _documents.where((d) => d.userId == userId).toList()
      ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
  }

  // Get documents by type
  Future<List<DocumentModel>> getDocumentsByType(
    String userId,
    DocumentType type,
  ) async {
    await _mockDelay();
    return _documents
        .where((d) => d.userId == userId && d.type == type)
        .toList()
      ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
  }

  // Upload document (mock)
  Future<DocumentModel> uploadDocument(DocumentModel document) async {
    await _mockDelay();
    // In real app, this would upload to cloud storage
    _documents.add(document);
    return document;
  }

  // Update document metadata
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    await _mockDelay();
    final index = _documents.indexWhere((d) => d.id == document.id);
    if (index == -1) {
      throw Exception('Document not found');
    }
    _documents[index] = document;
    return document;
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    await _mockDelay();
    _documents.removeWhere((d) => d.id == documentId);
  }

  // Share document with caregiver
  Future<DocumentModel> shareDocument(
    String documentId,
    DocumentVisibility visibility,
  ) async {
    await _mockDelay();
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index == -1) {
      throw Exception('Document not found');
    }

    final updatedDoc = _documents[index].copyWith(visibility: visibility);
    _documents[index] = updatedDoc;
    return updatedDoc;
  }

  // Get shared documents (for caregiver view)
  Future<List<DocumentModel>> getSharedDocuments(String patientId) async {
    await _mockDelay();
    return _documents
        .where(
          (d) =>
              d.userId == patientId &&
              (d.visibility == DocumentVisibility.sharedWithCaregiver ||
                  d.visibility == DocumentVisibility.public),
        )
        .toList()
      ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
  }

  // Initialize mock data
  void initializeMockData(String userId) {
    final now = DateTime.now();

    _documents.addAll([
      DocumentModel(
        id: 'doc-1',
        title: 'Blood Test Results - June 2025',
        type: DocumentType.labReport,
        filePath: 'mock://documents/blood-test-june.pdf',
        uploadDate: now.subtract(const Duration(days: 5)),
        visibility: DocumentVisibility.sharedWithCaregiver,
        description: 'Complete blood count and lipid panel',
        userId: userId,
      ),
      DocumentModel(
        id: 'doc-2',
        title: 'Metformin Prescription',
        type: DocumentType.prescription,
        filePath: 'mock://documents/metformin-rx.pdf',
        uploadDate: now.subtract(const Duration(days: 15)),
        visibility: DocumentVisibility.private,
        description: 'Dr. Smith - 500mg twice daily',
        userId: userId,
      ),
      DocumentModel(
        id: 'doc-3',
        title: 'Chest X-Ray',
        type: DocumentType.xray,
        filePath: 'mock://documents/chest-xray.jpg',
        uploadDate: now.subtract(const Duration(days: 30)),
        visibility: DocumentVisibility.sharedWithCaregiver,
        description: 'Annual checkup',
        userId: userId,
      ),
      DocumentModel(
        id: 'doc-4',
        title: 'Insurance Card',
        type: DocumentType.insurance,
        filePath: 'mock://documents/insurance-card.jpg',
        uploadDate: now.subtract(const Duration(days: 60)),
        visibility: DocumentVisibility.private,
        userId: userId,
      ),
      DocumentModel(
        id: 'doc-5',
        title: 'Hospital Discharge Summary',
        type: DocumentType.discharge,
        filePath: 'mock://documents/discharge-summary.pdf',
        uploadDate: now.subtract(const Duration(days: 90)),
        visibility: DocumentVisibility.sharedWithCaregiver,
        description: 'City Hospital - May 2025',
        userId: userId,
      ),
    ]);
  }
}
