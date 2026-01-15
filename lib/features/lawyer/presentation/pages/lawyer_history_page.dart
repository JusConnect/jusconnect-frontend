import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jusconnect/core/providers/request_providers.dart';
import 'package:jusconnect/features/request/domain/entities/request_entity.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

final lawyerHistoryProvider = FutureProvider<List<RequestEntity>>((ref) async {
  final useCase = ref.read(getMyRequestsLawyerUseCaseProvider);
  final result = await useCase();
  return result.fold((failure) => throw Exception(failure.message), (requests) {
    // Filter only completed requests (accepted or rejected)
    return requests
        .where(
          (r) =>
              r.status == 'ACEITA' ||
              r.status == 'RECUSADA' ||
              r.status == 'CANCELADA',
        )
        .toList();
  });
});

enum HistorySortType { dateDesc, dateAsc }

final historySortProvider = StateProvider<HistorySortType>(
  (ref) => HistorySortType.dateDesc,
);
final historyStatusFilterProvider = StateProvider<String?>((ref) => null);

class LawyerHistoryPage extends ConsumerWidget {
  const LawyerHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(lawyerHistoryProvider);
    final sortType = ref.watch(historySortProvider);
    final statusFilter = ref.watch(historyStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Histórico',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              sortType == HistorySortType.dateDesc
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            onPressed: () {
              ref
                  .read(historySortProvider.notifier)
                  .state = sortType == HistorySortType.dateDesc
                  ? HistorySortType.dateAsc
                  : HistorySortType.dateDesc;
            },
            tooltip: sortType == HistorySortType.dateDesc
                ? 'Ordenar por mais antigas'
                : 'Ordenar por mais recentes',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(ref, statusFilter),
          _buildStatsHeader(ref),
          Expanded(
            child: historyAsync.when(
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
                      'Erro ao carregar histórico',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(lawyerHistoryProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (requests) {
                var filteredRequests = List<RequestEntity>.from(requests);

                if (statusFilter != null) {
                  filteredRequests = requests
                      .where((r) => r.status == statusFilter)
                      .toList();
                }

                switch (sortType) {
                  case HistorySortType.dateDesc:
                    filteredRequests.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );
                    break;
                  case HistorySortType.dateAsc:
                    filteredRequests.sort(
                      (a, b) => a.createdAt.compareTo(b.createdAt),
                    );
                    break;
                }

                if (filteredRequests.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(lawyerHistoryProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) =>
                        _buildHistoryCard(context, filteredRequests[index]),
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
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(ref, 'Todas', selectedStatus == null, () {
            ref.read(historyStatusFilterProvider.notifier).state = null;
          }),
          _buildFilterChip(ref, 'Aceitas', selectedStatus == 'ACEITA', () {
            ref.read(historyStatusFilterProvider.notifier).state = 'ACEITA';
          }),
          _buildFilterChip(ref, 'Recusadas', selectedStatus == 'RECUSADA', () {
            ref.read(historyStatusFilterProvider.notifier).state = 'RECUSADA';
          }),
          _buildFilterChip(
            ref,
            'Canceladas',
            selectedStatus == 'CANCELADA',
            () {
              ref.read(historyStatusFilterProvider.notifier).state =
                  'CANCELADA';
            },
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

  Widget _buildStatsHeader(WidgetRef ref) {
    final historyAsync = ref.watch(lawyerHistoryProvider);

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        final accepted = requests.where((r) => r.status == 'ACEITA').length;
        final rejected = requests.where((r) => r.status == 'RECUSADA').length;
        final canceled = requests.where((r) => r.status == 'CANCELADA').length;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Aceitas',
                accepted.toString(),
                AppColors.successColor,
              ),
              Container(
                height: 30,
                width: 1,
                color: AppColors.secondaryDarkColor.withOpacity(0.2),
              ),
              _buildStatItem(
                'Recusadas',
                rejected.toString(),
                AppColors.errorColor,
              ),
              Container(
                height: 30,
                width: 1,
                color: AppColors.secondaryDarkColor.withOpacity(0.2),
              ),
              _buildStatItem(
                'Canceladas',
                canceled.toString(),
                AppColors.secondaryDarkColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.secondaryDarkColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.secondaryDarkColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum histórico encontrado',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas solicitações finalizadas aparecerão aqui',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.secondaryDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, RequestEntity request) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(request.status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                  child: Text(
                    request.clientName.isNotEmpty
                        ? request.clientName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkColor,
                        ),
                      ),
                      Text(
                        dateFormat.format(request.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
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
                    fontSize: 13,
                    color: AppColors.darkColor,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (request.responseDateTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppColors.secondaryDarkColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Respondido em ${dateFormat.format(request.responseDateTime!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.secondaryDarkColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(status),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
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
}
