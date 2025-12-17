import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class RegisterLawyerUseCase {
  final LawyerRepository repository;

  RegisterLawyerUseCase(this.repository);

  Future<Either<Failure, LawyerEntity>> call({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  }) {
    return repository.registerLawyer(
      name: name,
      cpf: cpf,
      email: email,
      phone: phone,
      password: password,
      areaOfExpertise: areaOfExpertise,
      description: description,
      videoUrl: videoUrl,
    );
  }
}
