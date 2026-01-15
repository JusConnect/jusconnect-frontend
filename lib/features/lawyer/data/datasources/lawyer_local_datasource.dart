import 'package:dio/dio.dart';
import 'package:jusconnect/features/lawyer/data/models/lawyer_model.dart';
import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';

abstract class ILawyerDataSource {
  Future<Either<Failure, LawyerModel>> registerLawyer({
    required LawyerModel lawyer,
  });

  Future<Either<Failure, void>> login(CredentialsEntity credentials);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, LawyerModel>> getCurrentLawyer();

  Future<Either<Failure, void>> updateLawyer(LawyerModel lawyer);

  Future<Either<Failure, List<LawyerModel>>> getAllLawyers({
    String? lawyerArea,
    int? monthsInPlatform,
  });
}

class LawyerLocalDataSourceImpl implements ILawyerDataSource {
  String? _authToken;
  final Dio _dio;

  LawyerLocalDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, LawyerModel>> registerLawyer({
    required LawyerModel lawyer,
  }) async {
    try {
      final data = lawyer.toJson();

      print(data);

      var result = await _dio.post('/advogados', data: data);

      if (result.statusCode == 201) {
        return Right(LawyerModel.fromJson(result.data));
      }

      return Left(AuthFailure('Erro ao criar advogado ${result.data}'));
    } catch (e) {
      return Left(AuthFailure('Erro ao criar advogado $e'));
    }
  }

  @override
  Future<Either<Failure, void>> login(CredentialsEntity credentials) async {
    try {
      var result = await _dio.post('/auth/login', data: credentials.toJson());
      if (result.statusCode == 200) {
        _authToken = result.data['token'];
        return Right(null);
      }
      return Left(AuthFailure('Erro ao fazer login ${result.data}'));
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    _authToken = null;
    return Right(null);
  }

  @override
  Future<Either<Failure, LawyerModel>> getCurrentLawyer() async {
    if (_authToken == null) {
      return Left(AuthFailure("Advogado não autenticado"));
    }

    try {
      var result = await _dio.get(
        '/advogados/me',
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      if (result.statusCode == 200) {
        return Right(LawyerModel.fromJson(result.data));
      }

      return Left(AuthFailure('Advogado não encontrado'));
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar advogado $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLawyer(LawyerModel lawyer) async {
    if (_authToken == null) {
      return Left(AuthFailure('Advogado não autenticado'));
    }

    try {
      var result = await _dio.put(
        '/advogados/me',
        data: lawyer.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        return Right(null);
      }

      return Left(AuthFailure('Erro ao atualizar advogado ${result.data}'));
    } catch (e) {
      return Left(AuthFailure('Erro ao atualizar advogado $e'));
    }
  }

  @override
  Future<Either<Failure, List<LawyerModel>>> getAllLawyers({
    String? lawyerArea,
    int? monthsInPlatform,
  }) async {
    try {
      var result = await _dio.get(
        '/advogados',
        queryParameters: {
          'areaAtuacao': lawyerArea,
          'tempoMinMeses': monthsInPlatform,
        },
      );

      if (result.statusCode == 200) {
        final List<dynamic> data = result.data as List<dynamic>;
        final lawyers = data
            .map((json) => LawyerModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(lawyers);
      }

      return Left(ServerFailure('Erro ao buscar advogados'));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar advogados: $e'));
    }
  }
}
