import 'package:jusconnect/features/lawyer/data/models/lawyer_model.dart';

abstract class LawyerLocalDataSource {
  Future<LawyerModel> registerLawyer({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  });

  Future<LawyerModel?> login(String cpf, String password);

  Future<void> logout();

  Future<LawyerModel?> getCurrentLawyer();

  Future<LawyerModel?> getLawyerById(String id);

  Future<LawyerModel> updateLawyer(LawyerModel lawyer);
}

class LawyerLocalDataSourceImpl implements LawyerLocalDataSource {
  final Map<String, LawyerModel> _lawyers = {};
  final Map<String, String> _credentials = {};
  String? _currentLawyerId;

  @override
  Future<LawyerModel> registerLawyer({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_credentials.containsKey(cpf)) {
      throw Exception('CPF já cadastrado');
    }

    final lawyer = LawyerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      cpf: cpf,
      email: email,
      phone: phone,
      areaOfExpertise: areaOfExpertise,
      description: description,
      videoUrl: videoUrl,
      createdAt: DateTime.now(),
    );

    _lawyers[lawyer.id] = lawyer;
    _credentials[cpf] = password;
    _currentLawyerId = lawyer.id;

    return lawyer;
  }

  @override
  Future<LawyerModel?> login(String cpf, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_credentials[cpf] != password) {
      return null;
    }

    final lawyer = _lawyers.values.firstWhere(
      (l) => l.cpf == cpf,
      orElse: () => throw Exception('Advogado não encontrado'),
    );

    _currentLawyerId = lawyer.id;
    return lawyer;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentLawyerId = null;
  }

  @override
  Future<LawyerModel?> getCurrentLawyer() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentLawyerId == null) {
      return null;
    }

    return _lawyers[_currentLawyerId];
  }

  @override
  Future<LawyerModel?> getLawyerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _lawyers[id];
  }

  @override
  Future<LawyerModel> updateLawyer(LawyerModel lawyer) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_lawyers.containsKey(lawyer.id)) {
      throw Exception('Advogado não encontrado');
    }

    _lawyers[lawyer.id] = lawyer;
    return lawyer;
  }
}
