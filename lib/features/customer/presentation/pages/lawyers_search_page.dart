import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/core/providers/lawyer_providers.dart';
import 'package:jusconnect/features/customer/presentation/pages/lawyer_detail_page.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

final lawyersListProvider = FutureProvider<List<LawyerEntity>>((ref) async {
  final useCase = ref.read(getAllLawyersUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (lawyers) => lawyers,
  );
});

final lawyerSearchQueryProvider = StateProvider<String>((ref) => '');
final lawyerAreaFilterProvider = StateProvider<String?>((ref) => null);

class LawyersSearchPage extends ConsumerStatefulWidget {
  const LawyersSearchPage({super.key});

  @override
  ConsumerState<LawyersSearchPage> createState() => _LawyersSearchPageState();
}

class _LawyersSearchPageState extends ConsumerState<LawyersSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<LawyerEntity> _allLawyers = [];
  List<LawyerEntity> _filteredLawyers = [];
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLawyers(String query, String? areaFilter) {
    setState(() {
      _filteredLawyers = _allLawyers.where((lawyer) {
        final matchesQuery =
            query.isEmpty ||
            lawyer.name.toLowerCase().contains(query.toLowerCase()) ||
            lawyer.areaOfExpertise.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            lawyer.description.toLowerCase().contains(query.toLowerCase());

        final matchesArea =
            areaFilter == null ||
            areaFilter.isEmpty ||
            lawyer.areaOfExpertise.toLowerCase().contains(
              areaFilter.toLowerCase(),
            );

        return matchesQuery && matchesArea;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lawyersAsync = ref.watch(lawyersListProvider);
    final searchQuery = ref.watch(lawyerSearchQueryProvider);
    final areaFilter = ref.watch(lawyerAreaFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buscar Advogados',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildAreaFilter(),
          Expanded(
            child: lawyersAsync.when(
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
                      'Erro ao carregar advogados',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(lawyersListProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (lawyers) {
                if (_allLawyers.isEmpty ||
                    _allLawyers.length != lawyers.length) {
                  _allLawyers = lawyers;
                  _filteredLawyers = lawyers;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _filterLawyers(searchQuery, areaFilter);
                  });
                }

                if (_filteredLawyers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.secondaryDarkColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum advogado encontrado',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.secondaryDarkColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(lawyersListProvider);
                  },
                  child: _isGridView ? _buildGridView() : _buildListView(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(lawyerSearchQueryProvider.notifier).state = value;
          _filterLawyers(value, ref.read(lawyerAreaFilterProvider));
        },
        decoration: InputDecoration(
          hintText: 'Buscar por nome, área ou descrição...',
          hintStyle: GoogleFonts.poppins(color: AppColors.secondaryDarkColor),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(lawyerSearchQueryProvider.notifier).state = '';
                    _filterLawyers('', ref.read(lawyerAreaFilterProvider));
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.lightColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAreaFilter() {
    final areas = _allLawyers.map((l) => l.areaOfExpertise).toSet().toList();
    final selectedArea = ref.watch(lawyerAreaFilterProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Todas', selectedArea == null, () {
            ref.read(lawyerAreaFilterProvider.notifier).state = null;
            _filterLawyers(ref.read(lawyerSearchQueryProvider), null);
          }),
          ...areas.map(
            (area) => _buildFilterChip(area, selectedArea == area, () {
              ref.read(lawyerAreaFilterProvider.notifier).state = area;
              _filterLawyers(ref.read(lawyerSearchQueryProvider), area);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
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

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredLawyers.length,
      itemBuilder: (context, index) =>
          _buildLawyerCard(_filteredLawyers[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLawyers.length,
      itemBuilder: (context, index) =>
          _buildLawyerListTile(_filteredLawyers[index]),
    );
  }

  Widget _buildLawyerCard(LawyerEntity lawyer) {
    return GestureDetector(
      onTap: () => _navigateToDetail(lawyer),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.8),
                    AppColors.secondaryColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    lawyer.name.isNotEmpty ? lawyer.name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lawyer.areaOfExpertise,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        lawyer.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.secondaryDarkColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToDetail(lawyer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Ver Perfil',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLawyerListTile(LawyerEntity lawyer) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
          child: Text(
            lawyer.name.isNotEmpty ? lawyer.name[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        title: Text(
          lawyer.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.darkColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lawyer.areaOfExpertise,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lawyer.description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.secondaryDarkColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
          color: AppColors.primaryColor,
          onPressed: () => _navigateToDetail(lawyer),
        ),
        onTap: () => _navigateToDetail(lawyer),
      ),
    );
  }

  void _navigateToDetail(LawyerEntity lawyer) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LawyerDetailPage(lawyer: lawyer)),
    );
  }
}
