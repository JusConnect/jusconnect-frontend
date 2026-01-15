import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jusconnect/core/providers/request_providers.dart';
import 'package:jusconnect/features/request/data/models/request_model.dart';
import 'package:jusconnect/features/request/domain/entities/request_entity.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

final lawyerRequestsProvider = FutureProvider<List<RequestEntity>>((ref) async {
  final myRequestsUseCase = ref.read(getMyRequestsLawyerUseCaseProvider);
  final publicRequestsUseCase = ref.read(getAllPublicRequestsUseCaseProvider);

  // Fetch both in parallel
  final results = await Future.wait([
    myRequestsUseCase(),
    publicRequestsUseCase(),
  ]);

  final myResult = results[0];
  final publicResult = results[1];

  final myRequests = myResult.fold(
    (failure) {
      debugPrint('Error fetching my requests: ${failure.message}');
      return <RequestEntity>[];
    },
    (requests) {
      debugPrint('My requests: ${requests.length}');
      return requests;
    },
  );

  final publicRequests = publicResult.fold(
    (failure) {
      debugPrint('Error fetching public requests: ${failure.message}');
      return <RequestEntity>[];
    },
    (requests) {
      debugPrint('Public requests: ${requests.length}');
      return requests;
    },
  );

  // Combine and deduplicate by ID
  final Map<int, RequestEntity> combined = {};
  for (final req in myRequests) {
    combined[req.id] = req;
  }
  for (final req in publicRequests) {
    if (!combined.containsKey(req.id)) {
      combined[req.id] = req;
    }
  }

  debugPrint('Total combined requests: ${combined.length}');
  return combined.values.toList();
});

// Stats provider for dashboard
class LawyerRequestsStats {
  final int pending;
  final int accepted;
  final int rejected;
  final int publicRequests;

  LawyerRequestsStats({
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.publicRequests,
  });
}

final lawyerRequestsStatsProvider = Provider<LawyerRequestsStats>((ref) {
  final requestsAsync = ref.watch(lawyerRequestsProvider);
  return requestsAsync.when(
    loading: () => LawyerRequestsStats(
      pending: 0,
      accepted: 0,
      rejected: 0,
      publicRequests: 0,
    ),
    error: (_, __) => LawyerRequestsStats(
      pending: 0,
      accepted: 0,
      rejected: 0,
      publicRequests: 0,
    ),
    data: (requests) {
      final pending = requests.where((r) => r.status == 'PENDENTE').length;
      final accepted = requests.where((r) => r.status == 'ACEITA').length;
      final rejected = requests.where((r) => r.status == 'RECUSADA').length;
      final publicReqs = requests.where((r) => r.public == true).length;
      return LawyerRequestsStats(
        pending: pending,
        accepted: accepted,
        rejected: rejected,
        publicRequests: publicReqs,
      );
    },
  );
});

final lawyerRequestStatusFilterProvider = StateProvider<String?>(
  (ref) => 'PENDENTE',
);

class LawyerRequestsPage extends ConsumerWidget {
  const LawyerRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(lawyerRequestsProvider);
    final statusFilter = ref.watch(lawyerRequestStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Solicitações',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildStatusTabs(ref, statusFilter),
          Expanded(
            child: requestsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar solicitações',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(lawyerRequestsProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (requests) {
                var filteredRequests = requests;

                if (statusFilter == 'PUBLICA') {
                  // Filter only public requests
                  filteredRequests = requests
                      .where((r) => r.public == true)
                      .toList();
                } else if (statusFilter != null) {
                  filteredRequests = requests
                      .where((r) => r.status == statusFilter)
                      .toList();
                }

                filteredRequests.sort(
                  (a, b) => b.createdAt.compareTo(a.createdAt),
                );

                if (filteredRequests.isEmpty) {
                  return _buildEmptyState(statusFilter);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(lawyerRequestsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) => _buildRequestCard(
                      context,
                      filteredRequests[index],
                      ref,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(WidgetRef ref, String? selectedStatus) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  ref,
                  'PENDENTE',
                  'Pendentes',
                  Icons.pending_actions,
                  selectedStatus,
                  AppColors.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTabButton(
                  ref,
                  'PUBLICA',
                  'Públicas',
                  Icons.public,
                  selectedStatus,
                  AppColors.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  ref,
                  'ACEITA',
                  'Aceitas',
                  Icons.check_circle_outline,
                  selectedStatus,
                  AppColors.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTabButton(
                  ref,
                  null,
                  'Todas',
                  Icons.list_alt,
                  selectedStatus,
                  AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isPublicRequest(RequestEntity request) {
    return request.public;
  }

  Widget _buildTabButton(
    WidgetRef ref,
    String? status,
    String label,
    IconData icon,
    String? selectedStatus,
    Color accentColor,
  ) {
    final isSelected = status == selectedStatus;

    return GestureDetector(
      onTap: () {
        ref.read(lawyerRequestStatusFilterProvider.notifier).state = status;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : AppColors.secondaryDarkColor.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : accentColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.darkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? statusFilter) {
    String message = 'Nenhuma solicitação encontrada';
    if (statusFilter == 'PENDENTE') {
      message = 'Nenhuma solicitação pendente';
    } else if (statusFilter == 'ACEITA') {
      message = 'Nenhuma solicitação aceita';
    } else if (statusFilter == 'PUBLICA') {
      message = 'Nenhuma solicitação pública disponível';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.secondaryDarkColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    RequestEntity request,
    WidgetRef ref,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(request.status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                  child: Text(
                    request.clientName.isNotEmpty
                        ? request.clientName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.clientName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkColor,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.secondaryDarkColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(request.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.secondaryDarkColor,
                            ),
                          ),
                          if (_isPublicRequest(request)) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 10,
                                    color: AppColors.accentColor,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Pública',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.darkColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (request.clientEmail.isNotEmpty ||
                    request.clientPhone.isNotEmpty) ...[
                  Divider(color: AppColors.secondaryDarkColor.withOpacity(0.2)),
                  const SizedBox(height: 8),
                  if (request.clientEmail.isNotEmpty)
                    _buildContactRow(Icons.email_outlined, request.clientEmail),
                  if (request.clientPhone.isNotEmpty)
                    _buildContactRow(Icons.phone_outlined, request.clientPhone),
                  const SizedBox(height: 8),
                ],
                if (request.status == 'PENDENTE')
                  _buildActionButtons(context, request, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryDarkColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.secondaryDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusLabel(status),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    RequestEntity request,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRejectDialog(context, request, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.errorColor,
              side: const BorderSide(color: AppColors.errorColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Recusar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showAcceptDialog(context, request, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Aceitar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDENTE':
        return AppColors.accentColor;
      case 'ACEITA':
        return AppColors.successColor;
      case 'RECUSADA':
        return AppColors.errorColor;
      case 'CANCELADA':
        return AppColors.secondaryDarkColor;
      default:
        return AppColors.secondaryDarkColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDENTE':
        return 'Pendente';
      case 'ACEITA':
        return 'Aceita';
      case 'RECUSADA':
        return 'Recusada';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return status;
    }
  }

  void _showAcceptDialog(
    BuildContext context,
    RequestEntity request,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppColors.successColor),
            ),
            const SizedBox(width: 12),
            Text(
              'Aceitar Solicitação',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Ao aceitar, o cliente será notificado e poderá entrar em contato com você.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.secondaryDarkColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: AppColors.secondaryDarkColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateRequestStatus(context, request, 'ACEITA', ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirmar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    RequestEntity request,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: AppColors.errorColor),
            ),
            const SizedBox(width: 12),
            Text(
              'Recusar Solicitação',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza que deseja recusar esta solicitação?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.secondaryDarkColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: AppColors.secondaryDarkColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateRequestStatus(context, request, 'RECUSADA', ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Recusar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRequestStatus(
    BuildContext context,
    RequestEntity request,
    String newStatus,
    WidgetRef ref,
  ) async {
    final useCase = ref.read(updateRequestUseCaseProvider);

    final requestModel = RequestModel(
      id: request.id,
      description: request.description,
      public: request.public,
      status: newStatus,
      lawyerId: request.lawyerId,
      lawyerName: request.lawyerName,
      clientId: request.clientId,
      clientName: request.clientName,
      clientEmail: request.clientEmail,
      clientPhone: request.clientPhone,
      createdAt: request.createdAt,
      responseDateTime: DateTime.now(),
    );

    final result = await useCase(requestModel);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.errorColor,
          ),
        );
      },
      (_) {
        ref.invalidate(lawyerRequestsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'ACEITA'
                  ? 'Solicitação aceita com sucesso!'
                  : 'Solicitação recusada',
            ),
            backgroundColor: newStatus == 'ACEITA'
                ? AppColors.successColor
                : AppColors.secondaryDarkColor,
          ),
        );
      },
    );
  }
}
