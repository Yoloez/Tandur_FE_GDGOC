import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/features/buyer/home/models/buyer_home_data.dart';
import 'package:tandur/features/buyer/home/services/buyer_home_service.dart';

class FarmerListProvider extends ChangeNotifier {
  List<FarmerItem> _farmers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<FarmerItem> get farmers => _farmers;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  FarmerListProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadFarmers(refresh: true);
  }

  Future<void> loadFarmers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _isLoading = true;
      _errorMessage = null;
      _hasMore = true;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final newFarmers = await BuyerHomeService.fetchFarmers(page: _currentPage, limit: 6);
      
      if (refresh) {
        _farmers = newFarmers;
      } else {
        _farmers.addAll(newFarmers);
      }

      if (newFarmers.length < 6) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      if (refresh) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      if (refresh) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }
}

class FarmerListScreen extends StatefulWidget {
  const FarmerListScreen({super.key});

  @override
  State<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen> {
  late final FarmerListProvider _provider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = FarmerListProvider();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _provider.loadFarmers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Daftar Petani',
          style: GoogleFonts.beVietnamPro(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          if (_provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (_provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _provider.errorMessage!,
                    style: GoogleFonts.inter(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _provider.loadFarmers(refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (_provider.farmers.isEmpty) {
            return Center(
              child: Text(
                'Belum ada petani terdaftar.',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _provider.loadFarmers(refresh: true),
            color: AppColors.primary,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _provider.farmers.length + (_provider.hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == _provider.farmers.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final farmer = _provider.farmers[index];
                return _buildFarmerListItem(farmer);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFarmerListItem(FarmerItem farmer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainer,
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1,
              ),
            ),
            child: farmer.avatarUrl != null && farmer.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      farmer.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.outline,
                        size: 30,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 30,
                    color: AppColors.outline,
                  ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmer.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  farmer.location,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF4A261)),
                    const SizedBox(width: 4),
                    Text(
                      farmer.rating.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
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
}
