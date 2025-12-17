import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/core/utils/notifications.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_provider.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_state.dart';
import 'package:jusconnect/features/profile/presentation/providers/profile_provider.dart';
import 'package:jusconnect/features/profile/presentation/providers/profile_state.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);

    if (authState is! AuthSuccessState) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil')),
        body: const Center(
          child: Text('Você precisa estar logado para editar o perfil'),
        ),
      );
    }

    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next is ProfileUpdated) {
        Notifications.showSuccess(context, 'Perfil atualizado com sucesso!');
        ref.read(authProvider.notifier).login(cpf: next.user.cpf, password: '');
        Navigator.of(context).pop();
      } else if (next is ProfileError) {
        Notifications.showError(context, next.message);
      }
    });

    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    'name': user.name,
                    'cpf': user.cpf,
                    'email': user.email,
                    'phone': user.phone,
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Informações Pessoais',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FormBuilderTextField(
                        name: 'name',
                        decoration: InputDecoration(
                          labelText: 'Nome Completo',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Campo obrigatório',
                          ),
                          FormBuilderValidators.minLength(
                            3,
                            errorText: 'Nome deve ter no mínimo 3 caracteres',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'cpf',
                        decoration: InputDecoration(
                          labelText: 'CPF',
                          prefixIcon: const Icon(Icons.credit_card),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: '000.000.000-00',
                        ),
                        enabled: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Campo obrigatório',
                          ),
                          (value) {
                            if (value == null || value.isEmpty) return null;
                            if (!CPFValidator.isValid(value)) {
                              return 'CPF inválido';
                            }
                            return null;
                          },
                        ]),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Informações de Contato',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FormBuilderTextField(
                        name: 'email',
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Campo obrigatório',
                          ),
                          FormBuilderValidators.email(
                            errorText: 'E-mail inválido',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'phone',
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: '(00) 00000-0000',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Campo obrigatório',
                          ),
                          FormBuilderValidators.minLength(
                            10,
                            errorText: 'Telefone deve ter no mínimo 10 dígitos',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: profileState is ProfileUpdating
                            ? null
                            : () {
                                if (_formKey.currentState?.saveAndValidate() ??
                                    false) {
                                  final values = _formKey.currentState!.value;
                                  final updatedUser = UserEntity(
                                    id: user.id,
                                    name: values['name'],
                                    cpf: values['cpf'],
                                    email: values['email'],
                                    phone: values['phone'],
                                  );
                                  ref
                                      .read(profileProvider.notifier)
                                      .updateProfile(updatedUser);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: profileState is ProfileUpdating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Salvar Alterações',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
