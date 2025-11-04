class DocumentModel {
  final String id;
  final String title;
  final DocumentType type;
  final String filePath; // Mock file path
  final DateTime uploadDate;
  final DocumentVisibility visibility;
  final String? description;
  final String userId;

  DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.filePath,
    required this.uploadDate,
    required this.visibility,
    this.description,
    required this.userId,
  });

  DocumentModel copyWith({
    String? id,
    String? title,
    DocumentType? type,
    String? filePath,
    DateTime? uploadDate,
    DocumentVisibility? visibility,
    String? description,
    String? userId,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      uploadDate: uploadDate ?? this.uploadDate,
      visibility: visibility ?? this.visibility,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString(),
      'filePath': filePath,
      'uploadDate': uploadDate.toIso8601String(),
      'visibility': visibility.toString(),
      'description': description,
      'userId': userId,
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      title: json['title'],
      type: DocumentType.values.firstWhere((e) => e.toString() == json['type']),
      filePath: json['filePath'],
      uploadDate: DateTime.parse(json['uploadDate']),
      visibility: DocumentVisibility.values.firstWhere(
        (e) => e.toString() == json['visibility'],
      ),
      description: json['description'],
      userId: json['userId'],
    );
  }
}

enum DocumentType {
  prescription,
  labReport,
  xray,
  scan,
  discharge,
  insurance,
  other,
}

enum DocumentVisibility { private, sharedWithCaregiver, public }

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.prescription:
        return 'Prescription';
      case DocumentType.labReport:
        return 'Lab Report';
      case DocumentType.xray:
        return 'X-Ray';
      case DocumentType.scan:
        return 'Scan';
      case DocumentType.discharge:
        return 'Discharge Summary';
      case DocumentType.insurance:
        return 'Insurance';
      case DocumentType.other:
        return 'Other';
    }
  }
}
