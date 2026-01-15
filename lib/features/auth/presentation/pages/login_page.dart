import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/core/utils/notifications.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_provider.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_state.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';
import 'package:jusconnect/shared/widgets/cpf_field.dart';
import 'package:jusconnect/shared/widgets/password_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthSuccessState) {
        Notifications.showSuccess(context, 'Login realizado com sucesso!');
        Navigator.of(context).pushReplacementNamed('/home');
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
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const .all(32.0),
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
          Icon(Icons.gavel, size: 64, color: AppColors.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Bem-vindo',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Entre para acessar sua conta',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          CpfField(referenceName: 'cpf'),

          const SizedBox(height: 16),

          PasswordField(referenceName: 'password'),

          const SizedBox(height: 24),

          submitButton(authState),

          const SizedBox(height: 16),

          formBottom(context),
        ],
      ),
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
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Entrar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget formBottom(BuildContext context) {
    return Wrap(
      alignment: .center,
      crossAxisAlignment: .center,
      children: [
        Text(
          'Não tem uma conta? ',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/register');
          },
          child: Text(
            'Cadastrar',
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

  void onSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      ref
          .read(authProvider.notifier)
          .login(cpf: values['cpf'], password: values['password']);
    }
  }
}
