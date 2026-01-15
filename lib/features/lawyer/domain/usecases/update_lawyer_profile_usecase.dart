import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/lawyer/data/models/lawyer_model.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class UpdateLawyerProfileUseCase {
  final LawyerRepository repository;

  UpdateLawyerProfileUseCase(this.repository);

  Future<Either<Failure, LawyerEntity>> call({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  }) {
    return repository.updateProfile(
      lawyer: LawyerModel(
        id: id,
        name: name,
        cpf: "temp_cpf",
        email: email,
        phone: phone,
        areaOfExpertise: areaOfExpertise,
        description: description,
        password: "temp_password",
      ),
    );
  }
}
