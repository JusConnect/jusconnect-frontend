import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/core/utils/notifications.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_provider.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_state.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';
import 'package:jusconnect/shared/widgets/cpf_field.dart';
import 'package:jusconnect/shared/widgets/email_field.dart';
import 'package:jusconnect/shared/widgets/loading_icon.dart';
import 'package:jusconnect/shared/widgets/password_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthSuccessState) {
        Notifications.showSuccess(context, 'Cadastro realizado com sucesso!');
        Navigator.of(context).pushReplacementNamed('/client/home');
      } else if (next is AuthErrorState) {
        Notifications.showError(context, next.message);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.1),
              AppColors.secondaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const .all(10),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32.0),
                child: form(authState, context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  FormBuilder form(AuthState authState, BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.person_add, size: 64, color: AppColors.primaryColor),

          const SizedBox(height: 16),

          Text(
            'Criar Conta',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Cadastre-se para acessar a assistência jurídica',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

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
              FormBuilderValidators.required(errorText: 'Campo obrigatório'),
              FormBuilderValidators.minLength(
                3,
                errorText: 'Nome deve ter no mínimo 3 caracteres',
              ),
            ]),
          ),

          const SizedBox(height: 16),

          CpfField(referenceName: 'cpf'),

          const SizedBox(height: 16),

          EmailField(referenceName: 'email'),

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
              FormBuilderValidators.required(errorText: 'Campo obrigatório'),
              FormBuilderValidators.minLength(
                10,
                errorText: 'Telefone deve ter no mínimo 10 dígitos',
              ),
            ]),
          ),

          const SizedBox(height: 16),

          PasswordField(
            referenceName: 'password',
            labelText: 'Senha',
            hintText: 'Digite sua senha',
          ),

          const SizedBox(height: 16),

          PasswordField(
            referenceName: 'confirmPassword',
            labelText: 'Confirmar Senha',
            hintText: 'Confirme sua senha',
          ),

          const SizedBox(height: 24),

          submitButton(authState),

          const SizedBox(height: 16),

          formBottom(context),
        ],
      ),
    );
  }

  Widget formBottom(BuildContext context) {
    return Wrap(
      alignment: .center,
      crossAxisAlignment: .center,
      children: [
        Text(
          'Já tem uma conta? ',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text(
            'Entrar',
            style: GoogleFonts.poppins(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
          child: Text(
            'Voltar para seleção de tipo',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget submitButton(AuthState authState) {
    return ElevatedButton(
      onPressed: authState is AuthLoadingState ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: authState is AuthLoadingState
          ? const LoadingIcon(size: 24)
          : Text(
              'Cadastrar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  void onSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      ref
          .read(authProvider.notifier)
          .register(
            name: values['name'],
            cpf: values['cpf'],
            email: values['email'],
            phone: values['phone'],
            password: values['password'],
          );
    }
  }
}
