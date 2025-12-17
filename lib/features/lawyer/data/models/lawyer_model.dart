import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';

class LawyerModel extends LawyerEntity {
  const LawyerModel({
    required super.id,
    required super.name,
    required super.cpf,
    required super.email,
    required super.phone,
    required super.areaOfExpertise,
    required super.description,
    super.videoUrl,
    required super.createdAt,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    return LawyerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      areaOfExpertise: json['areaOfExpertise'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'email': email,
      'phone': phone,
      'areaOfExpertise': areaOfExpertise,
      'description': description,
      'videoUrl': videoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LawyerModel.fromEntity(LawyerEntity entity) {
    return LawyerModel(
      id: entity.id,
      name: entity.name,
      cpf: entity.cpf,
      email: entity.email,
      phone: entity.phone,
      areaOfExpertise: entity.areaOfExpertise,
      description: entity.description,
      videoUrl: entity.videoUrl,
      createdAt: entity.createdAt,
    );
  }
}
