import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jusconnect/core/providers/request_providers.dart';
import 'package:jusconnect/features/request/domain/entities/request_entity.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

final clientRequestsProvider = FutureProvider<List<RequestEntity>>((ref) async {
  final useCase = ref.read(getMyRequestsClientUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (requests) => requests,
  );
});

enum RequestSortType { dateDesc, dateAsc, status }

final requestSortProvider = StateProvider<RequestSortType>(
  (ref) => RequestSortType.dateDesc,
);
final requestStatusFilterProvider = StateProvider<String?>((ref) => null);

class ClientRequestsPage extends ConsumerWidget {
  const ClientRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(clientRequestsProvider);
    final sortType = ref.watch(requestSortProvider);
    final statusFilter = ref.watch(requestStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Minhas Solicitações',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<RequestSortType>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              ref.read(requestSortProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: RequestSortType.dateDesc,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 18,
                      color: sortType == RequestSortType.dateDesc
                          ? AppColors.primaryColor
                          : AppColors.secondaryDarkColor,
                    ),
                    const SizedBox(width: 8),
                    Text('Mais recentes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: RequestSortType.dateAsc,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 18,
                      color: sortType == RequestSortType.dateAsc
                          ? AppColors.primaryColor
                          : AppColors.secondaryDarkColor,
                    ),
                    const SizedBox(width: 8),
                    Text('Mais antigas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: RequestSortType.status,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: sortType == RequestSortType.status
                          ? AppColors.primaryColor
                          : AppColors.secondaryDarkColor,
                    ),
                    const SizedBox(width: 8),
                    Text('Por status'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(ref, statusFilter),
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
                      onPressed: () => ref.refresh(clientRequestsProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (requests) {
                var filteredRequests = requests;

                if (statusFilter != null) {
                  filteredRequests = requests
                      .where((r) => r.status == statusFilter)
                      .toList();
                }

                switch (sortType) {
                  case RequestSortType.dateDesc:
                    filteredRequests.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );
                    break;
                  case RequestSortType.dateAsc:
                    filteredRequests.sort(
                      (a, b) => a.createdAt.compareTo(b.createdAt),
                    );
                    break;
                  case RequestSortType.status:
                    filteredRequests.sort(
                      (a, b) => a.status.compareTo(b.status),
                    );
                    break;
                }

                if (filteredRequests.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(clientRequestsProvider);
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

  Widget _buildStatusFilter(WidgetRef ref, String? selectedStatus) {
    final statuses = ['PENDENTE', 'ACEITA', 'RECUSADA', 'CANCELADA'];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(ref, 'Todas', selectedStatus == null, () {
            ref.read(requestStatusFilterProvider.notifier).state = null;
          }),
          ...statuses.map(
            (status) => _buildFilterChip(
              ref,
              _getStatusLabel(status),
              selectedStatus == status,
              () {
                ref.read(requestStatusFilterProvider.notifier).state = status;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.darkColor,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryColor,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.secondaryDarkColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: AppColors.secondaryDarkColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma solicitação encontrada',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Busque um advogado e faça sua primeira solicitação!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.secondaryDarkColor,
            ),
            textAlign: TextAlign.center,
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
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Text(
                    (request.lawyerName?.isNotEmpty ?? false)
                        ? request.lawyerName![0].toUpperCase()
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
                        request.lawyerName ?? 'Solicitação Pública',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkColor,
                        ),
                      ),
                      Text(
                        dateFormat.format(request.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.secondaryDarkColor,
                        ),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      request.public ? Icons.public : Icons.lock_outline,
                      size: 16,
                      color: AppColors.secondaryDarkColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.public ? 'Pública' : 'Privada',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.secondaryDarkColor,
                      ),
                    ),
                    const Spacer(),
                    if (request.status == 'PENDENTE')
                      TextButton(
                        onPressed: () =>
                            _showCancelDialog(context, request, ref),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.errorColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
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

  void _showCancelDialog(
    BuildContext context,
    RequestEntity request,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar Solicitação',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja cancelar esta solicitação?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Não',
              style: GoogleFonts.poppins(color: AppColors.secondaryDarkColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final useCase = ref.read(cancelRequestUseCaseProvider);
              final result = await useCase(request.id);
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
                  ref.invalidate(clientRequestsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Solicitação cancelada'),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
