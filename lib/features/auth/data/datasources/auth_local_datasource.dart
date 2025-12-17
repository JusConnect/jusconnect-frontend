import 'package:jusconnect/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> removeUser();
  Future<UserModel?> getUserByCpf(String cpf);
  Future<List<UserModel>> getAllUsers();
  Future<void> saveUserWithPassword(UserModel user, String password);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Map<String, UserModel> _users = {};
  final Map<String, String> _passwords = {};
  UserModel? _currentUser;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _users[user.cpf] = user;
    _currentUser = user;
  }

  @override
  Future<void> removeUser() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> getUserByCpf(String cpf) async {
    return _users[cpf];
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    return _users.values.toList();
  }

  @override
  Future<void> saveUserWithPassword(UserModel user, String password) async {
    _users[user.cpf] = user;
    _passwords[user.cpf] = password;
    _currentUser = user;
  }

  Future<bool> validatePassword(String cpf, String password) async {
    return _passwords[cpf] == password;
  }
}
