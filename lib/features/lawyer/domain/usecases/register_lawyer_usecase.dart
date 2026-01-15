import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/lawyer/data/models/lawyer_model.dart';
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
  }) async {
    var result = await repository.registerLawyer(
      lawyer: LawyerModel(
        id: 0,
        name: name,
        cpf: cpf,
        email: email,
        phone: phone,
        areaOfExpertise: areaOfExpertise,
        description: description,
        password: password,
      ),
    );

    var loginResult = await repository.login(
      CredentialsEntity(cpf: cpf, password: password),
    );
    var loginFailure = loginResult.fold<Failure?>((l) => l, (_) => null);
    if (loginFailure != null) {
      return Left(loginFailure);
    }

    return result;
  }
}
