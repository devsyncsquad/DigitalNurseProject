import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load documents
  Future<void> loadDocuments(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = await _documentService.getDocuments(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get documents by type
  Future<List<DocumentModel>> getDocumentsByType(
    String userId,
    DocumentType type,
  ) async {
    return await _documentService.getDocumentsByType(userId, type);
  }

  // Upload document
  Future<bool> uploadDocument(DocumentModel document) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uploaded = await _documentService.uploadDocument(document);
      _documents.insert(0, uploaded);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update document
  Future<bool> updateDocument(DocumentModel document) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _documentService.updateDocument(document);
      final index = _documents.indexWhere((d) => d.id == document.id);
      if (index != -1) {
        _documents[index] = updated;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete document
  Future<bool> deleteDocument(String documentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _documentService.deleteDocument(documentId);
      _documents.removeWhere((d) => d.id == documentId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Share document
  Future<bool> shareDocument(
    String documentId,
    DocumentVisibility visibility,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _documentService.shareDocument(
        documentId,
        visibility,
      );
      final index = _documents.indexWhere((d) => d.id == documentId);
      if (index != -1) {
        _documents[index] = updated;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Initialize mock data
  Future<void> initializeMockData(String userId) async {
    _documentService.initializeMockData(userId);
    await loadDocuments(userId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
