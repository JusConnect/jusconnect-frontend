import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_auth_provider.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_auth_state.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_profile_provider.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_profile_state.dart';
import 'package:jusconnect/features/lawyer/presentation/widgets/video_player_widget.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class LawyerProfilePage extends ConsumerStatefulWidget {
  const LawyerProfilePage({super.key});

  @override
  ConsumerState<LawyerProfilePage> createState() => _LawyerProfilePageState();
}

class _LawyerProfilePageState extends ConsumerState<LawyerProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(lawyerAuthProvider);
      if (authState is LawyerAuthSuccess) {
        ref
            .read(lawyerProfileProvider.notifier)
            .loadProfile(authState.lawyer.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(lawyerAuthProvider);
    final profileState = ref.watch(lawyerProfileProvider);

    if (authState is! LawyerAuthSuccess) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Perfil',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: Text('Erro ao carregar perfil')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meu Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(lawyerAuthProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: profileState is LawyerProfileLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState is LawyerProfileError
          ? _buildErrorView(profileState.message)
          : _buildProfileView(authState.lawyer),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar perfil',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(LawyerEntity lawyer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryColor.withValues(
                          alpha: 0.2,
                        ),
                        child: Icon(
                          Icons.gavel,
                          size: 50,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lawyer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lawyer.areaOfExpertise,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Informações Profissionais',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed('/lawyer/profile/edit');
                            },
                            tooltip: 'Editar',
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(lawyer),
                    ],
                  ),
                ),
              ),
              if (lawyer.videoUrl != null) ...[
                const SizedBox(height: 16),
                _buildVideoSection(lawyer.videoUrl!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(LawyerEntity lawyer) {
    return Column(
      children: [
        _buildInfoRow(icon: Icons.person, label: 'Nome', value: lawyer.name),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.credit_card,
          label: 'CPF',
          value: _formatCPF(lawyer.cpf),
        ),
        const SizedBox(height: 24),
        Text(
          'Informações de Contato',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(icon: Icons.email, label: 'E-mail', value: lawyer.email),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.phone,
          label: 'Telefone',
          value: _formatPhone(lawyer.phone),
        ),
        const SizedBox(height: 24),
        Text(
          'Sobre',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            lawyer.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection(String videoUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vídeo de Apresentação',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            VideoPlayerWidget(videoUrl: videoUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCPF(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  String _formatPhone(String phone) {
    if (phone.length == 11) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    }
    return phone;
  }
}
