import 'package:equatable/equatable.dart';

class LawyerEntity extends Equatable {
  final String id;
  final String name;
  final String cpf;
  final String email;
  final String phone;
  final String areaOfExpertise;
  final String description;
  final String? videoUrl;
  final DateTime createdAt;

  const LawyerEntity({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.phone,
    required this.areaOfExpertise,
    required this.description,
    this.videoUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    cpf,
    email,
    phone,
    areaOfExpertise,
    description,
    videoUrl,
    createdAt,
  ];
}
