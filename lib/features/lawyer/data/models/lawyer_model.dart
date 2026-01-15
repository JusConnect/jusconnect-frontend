import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';

class LawyerModel extends LawyerEntity {
  final String? password;
  const LawyerModel({
    required super.id,
    required super.name,
    required super.cpf,
    required super.email,
    required super.phone,
    required super.areaOfExpertise,
    required super.description,
    super.videoUrl,
    required this.password,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    return LawyerModel(
      id: json['id'] as int,
      name: json['nome'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      phone: json['telefone'] as String,
      areaOfExpertise: json['area_de_atuacao'] as String,
      description: json['autodescricao'] as String,
      videoUrl: json['videoUrl'] as String?,
      password: json['senha'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': name,
      'cpf': cpf,
      'email': email,
      'telefone': phone,
      'area_de_atuacao': areaOfExpertise,
      'autodescricao': description,
      'senha': password,
      if (videoUrl != null) 'videoUrl': videoUrl,
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
      password: null,
    );
  }

  LawyerModel copyWith({
    int? id,
    String? name,
    String? cpf,
    String? email,
    String? phone,
    String? areaOfExpertise,
    String? description,
    String? videoUrl,
    String? password,
  }) {
    return LawyerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      areaOfExpertise: areaOfExpertise ?? this.areaOfExpertise,
      description: description ?? this.description,
      password: password ?? this.password,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
