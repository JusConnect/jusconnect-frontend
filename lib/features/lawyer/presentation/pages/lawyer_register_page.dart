import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/core/widgets/video_upload_field.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_auth_provider.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_auth_state.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class LawyerRegisterPage extends ConsumerStatefulWidget {
  const LawyerRegisterPage({super.key});

  @override
  ConsumerState<LawyerRegisterPage> createState() => _LawyerRegisterPageState();
}

class _LawyerRegisterPageState extends ConsumerState<LawyerRegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _videoUrl;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(lawyerAuthProvider);

    ref.listen<LawyerAuthState>(lawyerAuthProvider, (previous, next) {
      if (next is LawyerAuthSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/lawyer/home');
      } else if (next is LawyerAuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
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
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32.0),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 24),
                      _buildProfessionalSection(),
                      const SizedBox(height: 24),
                      _buildPasswordSection(),
                      const SizedBox(height: 24),
                      _buildVideoSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(authState),
                      const SizedBox(height: 16),
                      _buildLoginLink(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.gavel, size: 64, color: AppColors.primaryColor),
        const SizedBox(height: 16),
        Text(
          'Cadastro de Advogado',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Junte-se à rede de profissionais do JusConnect',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações Pessoais'),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'name',
          decoration: InputDecoration(
            labelText: 'Nome Completo',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        FormBuilderTextField(
          name: 'cpf',
          decoration: InputDecoration(
            labelText: 'CPF',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: '000.000.000-00',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
            (value) {
              if (value != null && !CPFValidator.isValid(value)) {
                return 'CPF inválido';
              }
              return null;
            },
          ]),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações de Contato'),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'email',
          decoration: InputDecoration(
            labelText: 'E-mail',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.emailAddress,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
            FormBuilderValidators.email(errorText: 'E-mail inválido'),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'phone',
          decoration: InputDecoration(
            labelText: 'Telefone',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      ],
    );
  }

  Widget _buildProfessionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações Profissionais'),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'areaOfExpertise',
          decoration: InputDecoration(
            labelText: 'Área de Atuação',
            prefixIcon: const Icon(Icons.work),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'Ex: Direito Civil, Direito Trabalhista',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
            FormBuilderValidators.minLength(
              3,
              errorText: 'Área deve ter no mínimo 3 caracteres',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'description',
          decoration: InputDecoration(
            labelText: 'Sobre Você',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'Descreva sua experiência e especialidades...',
          ),
          maxLines: 4,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
            FormBuilderValidators.minLength(
              20,
              errorText: 'Descrição deve ter no mínimo 20 caracteres',
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Segurança'),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'password',
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          obscureText: _obscurePassword,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
            FormBuilderValidators.minLength(
              6,
              errorText: 'Senha deve ter no mínimo 6 caracteres',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'confirmPassword',
          decoration: InputDecoration(
            labelText: 'Confirmar Senha',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          obscureText: _obscureConfirmPassword,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Campo obrigatório'),
            (value) {
              final password = _formKey.currentState?.fields['password']?.value;
              if (value != password) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ]),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vídeo de Apresentação (Opcional)'),
        const SizedBox(height: 16),
        VideoUploadField(
          videoUrl: _videoUrl,
          onUpload: _handleVideoUpload,
          onRemove: () {
            setState(() {
              _videoUrl = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildSubmitButton(LawyerAuthState authState) {
    final isLoading = authState is LawyerAuthLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: Colors.grey[400],
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Cadastrar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem uma conta? ',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/lawyer/login');
          },
          child: Text(
            'Fazer Login',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _handleVideoUpload() {
    setState(() {
      _videoUrl =
          'https://example.com/video/${DateTime.now().millisecondsSinceEpoch}.mp4';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vídeo carregado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      ref
          .read(lawyerAuthProvider.notifier)
          .register(
            name: values['name'] as String,
            cpf: values['cpf'] as String,
            email: values['email'] as String,
            phone: values['phone'] as String,
            password: values['password'] as String,
            areaOfExpertise: values['areaOfExpertise'] as String,
            description: values['description'] as String,
            videoUrl: _videoUrl,
          );
    }
  }
}
