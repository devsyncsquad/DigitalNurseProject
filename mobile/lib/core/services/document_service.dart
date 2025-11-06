import 'dart:io';
import 'package:dio/dio.dart';
import '../models/document_model.dart';
import '../mappers/document_mapper.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'token_service.dart';

class DocumentService {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  void _log(String message) {
    print('🔍 [DOCUMENT] $message');
  }

  // Get all documents for a user
  Future<List<DocumentModel>> getDocuments(String userId) async {
    _log('📋 Fetching documents for user: $userId');
    try {
      final response = await _apiService.get('/documents');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final documents = data
            .map((json) => DocumentMapper.fromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList()
          ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        _log('✅ Fetched ${documents.length} documents');
        return documents;
      } else {
        _log('❌ Failed to fetch documents: ${response.statusMessage}');
        throw Exception('Failed to fetch documents: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching documents: $e');
      throw Exception(e.toString());
    }
  }

  // Get documents by type
  Future<List<DocumentModel>> getDocumentsByType(
    String userId,
    DocumentType type,
  ) async {
    _log('📋 Fetching documents by type: $type for user: $userId');
    try {
      // Convert type enum to string
      String typeStr;
      switch (type) {
        case DocumentType.prescription:
          typeStr = 'prescription';
          break;
        case DocumentType.labReport:
          typeStr = 'labReport';
          break;
        case DocumentType.xray:
          typeStr = 'xray';
          break;
        case DocumentType.scan:
          typeStr = 'scan';
          break;
        case DocumentType.discharge:
          typeStr = 'discharge';
          break;
        case DocumentType.insurance:
          typeStr = 'insurance';
          break;
        case DocumentType.other:
          typeStr = 'other';
          break;
      }

      final response = await _apiService.get(
        '/documents',
        queryParameters: {'type': typeStr},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final documents = data
            .map((json) => DocumentMapper.fromApiResponse(
                json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)))
            .toList()
          ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        _log('✅ Fetched ${documents.length} documents of type $type');
        return documents;
      } else {
        _log('❌ Failed to fetch documents by type: ${response.statusMessage}');
        throw Exception('Failed to fetch documents by type: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error fetching documents by type: $e');
      throw Exception(e.toString());
    }
  }

  // Upload document with file
  Future<DocumentModel> uploadDocument({
    required String filePath,
    required String title,
    required DocumentType type,
    required DocumentVisibility visibility,
    String? description,
  }) async {
    _log('📤 Uploading document: $title');
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Prepare form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: file.path.split('/').last,
        ),
        'title': title,
        'type': _documentTypeToString(type),
        'visibility': _documentVisibilityToString(visibility),
        if (description != null) 'description': description,
      });

      // Use Dio directly for multipart upload
      // For multipart, we need to use Dio directly
      final baseUrl = await AppConfig.getBaseUrl();
      final token = await _getAuthToken();
      
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ));

      final response = await dio.post(
        '/documents',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final uploadedDocument = DocumentMapper.fromApiResponse(response.data);
        _log('✅ Document uploaded successfully: ${uploadedDocument.title}');
        return uploadedDocument;
      } else {
        _log('❌ Failed to upload document: ${response.statusMessage}');
        throw Exception('Failed to upload document: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error uploading document: $e');
      throw Exception(e.toString());
    }
  }

  // Update document metadata
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    _log('✏️ Updating document: ${document.id}');
    try {
      final requestData = DocumentMapper.toApiRequest(document);
      final response = await _apiService.patch(
        '/documents/${document.id}',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final updatedDocument = DocumentMapper.fromApiResponse(response.data);
        _log('✅ Document updated successfully');
        return updatedDocument;
      } else {
        _log('❌ Failed to update document: ${response.statusMessage}');
        throw Exception('Failed to update document: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error updating document: $e');
      throw Exception(e.toString());
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    _log('🗑️ Deleting document: $documentId');
    try {
      final response = await _apiService.delete('/documents/$documentId');

      if (response.statusCode == 200) {
        _log('✅ Document deleted successfully');
      } else {
        _log('❌ Failed to delete document: ${response.statusMessage}');
        throw Exception('Failed to delete document: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error deleting document: $e');
      throw Exception(e.toString());
    }
  }

  // Share document with caregiver (update visibility)
  Future<DocumentModel> shareDocument(
    String documentId,
    DocumentVisibility visibility,
  ) async {
    _log('🔗 Sharing document: $documentId with visibility: $visibility');
    try {
      final response = await _apiService.patch(
        '/documents/$documentId/visibility',
        data: {'visibility': _documentVisibilityToString(visibility)},
      );

      if (response.statusCode == 200) {
        final updatedDocument = DocumentMapper.fromApiResponse(response.data);
        _log('✅ Document visibility updated successfully');
        return updatedDocument;
      } else {
        _log('❌ Failed to update document visibility: ${response.statusMessage}');
        throw Exception('Failed to update document visibility: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error updating document visibility: $e');
      throw Exception(e.toString());
    }
  }

  // Get shared documents (for caregiver view)
  Future<List<DocumentModel>> getSharedDocuments(String patientId) async {
    _log('📋 Fetching shared documents for patient: $patientId');
    // This would require a specific endpoint for caregivers
    // For now, we'll filter by visibility
    try {
      final allDocuments = await getDocuments(patientId);
      final sharedDocuments = allDocuments
          .where((d) =>
              d.visibility == DocumentVisibility.sharedWithCaregiver ||
              d.visibility == DocumentVisibility.public)
          .toList();
      _log('✅ Fetched ${sharedDocuments.length} shared documents');
      return sharedDocuments;
    } catch (e) {
      _log('❌ Error fetching shared documents: $e');
      throw Exception(e.toString());
    }
  }

  // Download document file
  Future<String> downloadDocument(String documentId, String savePath) async {
    _log('📥 Downloading document: $documentId');
    try {
      final baseUrl = await AppConfig.getBaseUrl();
      final token = await _getAuthToken();
      
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ));

      final response = await dio.get(
        '/documents/$documentId/file',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.data);
        _log('✅ Document downloaded successfully to: $savePath');
        return savePath;
      } else {
        _log('❌ Failed to download document: ${response.statusMessage}');
        throw Exception('Failed to download document: ${response.statusMessage}');
      }
    } catch (e) {
      _log('❌ Error downloading document: $e');
      throw Exception(e.toString());
    }
  }

  // Helper methods
  String _documentTypeToString(DocumentType type) {
    switch (type) {
      case DocumentType.prescription:
        return 'prescription';
      case DocumentType.labReport:
        return 'labReport';
      case DocumentType.xray:
        return 'xray';
      case DocumentType.scan:
        return 'scan';
      case DocumentType.discharge:
        return 'discharge';
      case DocumentType.insurance:
        return 'insurance';
      case DocumentType.other:
        return 'other';
    }
  }

  String _documentVisibilityToString(DocumentVisibility visibility) {
    switch (visibility) {
      case DocumentVisibility.private:
        return 'private';
      case DocumentVisibility.sharedWithCaregiver:
        return 'sharedWithCaregiver';
      case DocumentVisibility.public:
        return 'public';
    }
  }

  // Helper to get auth token
  Future<String?> _getAuthToken() async {
    return await _tokenService.getAccessToken();
  }
}
