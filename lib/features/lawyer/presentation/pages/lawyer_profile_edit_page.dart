import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/core/widgets/video_upload_field.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_auth_provider.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_auth_state.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_profile_provider.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_profile_state.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class LawyerProfileEditPage extends ConsumerStatefulWidget {
  const LawyerProfileEditPage({super.key});

  @override
  ConsumerState<LawyerProfileEditPage> createState() =>
      _LawyerProfileEditPageState();
}

class _LawyerProfileEditPageState extends ConsumerState<LawyerProfileEditPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _videoUrl;
  LawyerEntity? _currentLawyer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(lawyerAuthProvider);
      if (authState is LawyerAuthSuccess) {
        setState(() {
          _currentLawyer = authState.lawyer;
          _videoUrl = authState.lawyer.videoUrl;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(lawyerAuthProvider);
    final profileState = ref.watch(lawyerProfileProvider);

    ref.listen<LawyerProfileState>(lawyerProfileProvider, (previous, next) {
      if (next is LawyerProfileUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (next is LawyerProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    if (authState is! LawyerAuthSuccess || _currentLawyer == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Editar Perfil',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                'name': _currentLawyer!.name,
                'cpf': _currentLawyer!.cpf,
                'email': _currentLawyer!.email,
                'phone': _currentLawyer!.phone,
                'areaOfExpertise': _currentLawyer!.areaOfExpertise,
                'description': _currentLawyer!.description,
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Informações Pessoais'),
                  const SizedBox(height: 16),
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
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Informações de Contato'),
                  const SizedBox(height: 16),
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
                      FormBuilderValidators.email(errorText: 'E-mail inválido'),
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
                  const SizedBox(height: 24),
                  _buildSectionTitle('Informações Profissionais'),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'areaOfExpertise',
                    decoration: InputDecoration(
                      labelText: 'Área de Atuação',
                      prefixIcon: const Icon(Icons.work),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 4,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Campo obrigatório',
                      ),
                      FormBuilderValidators.minLength(
                        20,
                        errorText: 'Descrição deve ter no mínimo 20 caracteres',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Vídeo de Apresentação'),
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
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: profileState is LawyerProfileUpdating
                        ? null
                        : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: profileState is LawyerProfileUpdating
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
          .read(lawyerProfileProvider.notifier)
          .updateProfile(
            id: _currentLawyer!.id,
            name: values['name'] as String,
            email: values['email'] as String,
            phone: values['phone'] as String,
            areaOfExpertise: values['areaOfExpertise'] as String,
            description: values['description'] as String,
            videoUrl: _videoUrl,
          );
    }
  }
}
