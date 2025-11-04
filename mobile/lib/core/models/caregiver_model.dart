class CaregiverModel {
  final String id;
  final String name;
  final String phone;
  final CaregiverStatus status;
  final String? relationship;
  final String linkedPatientId;
  final DateTime invitedAt;
  final DateTime? acceptedAt;

  CaregiverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    this.relationship,
    required this.linkedPatientId,
    required this.invitedAt,
    this.acceptedAt,
  });

  CaregiverModel copyWith({
    String? id,
    String? name,
    String? phone,
    CaregiverStatus? status,
    String? relationship,
    String? linkedPatientId,
    DateTime? invitedAt,
    DateTime? acceptedAt,
  }) {
    return CaregiverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      relationship: relationship ?? this.relationship,
      linkedPatientId: linkedPatientId ?? this.linkedPatientId,
      invitedAt: invitedAt ?? this.invitedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'status': status.toString(),
      'relationship': relationship,
      'linkedPatientId': linkedPatientId,
      'invitedAt': invitedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  factory CaregiverModel.fromJson(Map<String, dynamic> json) {
    return CaregiverModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      status: CaregiverStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      relationship: json['relationship'],
      linkedPatientId: json['linkedPatientId'],
      invitedAt: DateTime.parse(json['invitedAt']),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
    );
  }
}

enum CaregiverStatus { pending, accepted, declined }
