import 'package:cpf_cnpj_validator/cpf_validator.dart';

class Validators {
  static String? validateCpf(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!CPFValidator.isValid(value)) {
      return 'CPF inválido';
    }
    return null;
  }
}
