import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/features/buyer/home/models/buyer_home_data.dart';
import 'providers/buyer_market_provider.dart';

class BuyerMarketScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final String? initialCategoryName;

  const BuyerMarketScreen({
    super.key,
    this.initialSearchQuery,
    this.initialCategoryName,
  });

  @override
  State<BuyerMarketScreen> createState() => _BuyerMarketScreenState();
}

class _BuyerMarketScreenState extends State<BuyerMarketScreen> {
  late final BuyerMarketProvider _provider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = BuyerMarketProvider();
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _provider.initialize(
      initialSearchQuery: widget.initialSearchQuery,
      initialCategoryName: widget.initialCategoryName,
    );
  }

  @override
  void didUpdateWidget(covariant BuyerMarketScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSearchQuery != oldWidget.initialSearchQuery ||
        widget.initialCategoryName != oldWidget.initialCategoryName) {
      if (widget.initialSearchQuery != null &&
          widget.initialSearchQuery != oldWidget.initialSearchQuery) {
        _searchController.text = widget.initialSearchQuery!;
      }

      _provider.initialize(
        initialSearchQuery: widget.initialSearchQuery,
        initialCategoryName: widget.initialCategoryName,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _provider,
          builder: (context, _) {
            return Column(
              children: [
                // ── Header ──
                _buildHeader(),

                // ── Search Bar ──
                _buildSearchBar(),

                // ── Category Chips ──
                _buildCategoryRow(),

                const SizedBox(height: 10),

                // ── Products + Pagination ──
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pasar Tandur',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Produk segar langsung dari petani lokal',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_provider.meta.total > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_provider.meta.total} produk',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _provider.setSearchQuery(value.trim());
        },
        decoration: InputDecoration(
          hintText: 'Cari barang di pasar...',
          hintStyle: GoogleFonts.beVietnamPro(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          suffixIcon:
              _provider.searchQuery != null && _provider.searchQuery!.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _provider.clearSearchQuery();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  Widget _buildCategoryRow() {
    return _provider.isLoadingCategories
        ? const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSortButton(),
                const SizedBox(width: 10),
                _CategoryChip(
                  label: 'Semua',
                  isSelected: _provider.selectedCategory == null,
                  onTap: () => _provider.setCategory(null),
                ),
                const SizedBox(width: 10),
                ..._provider.apiCategories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryChip(
                      label: cat.nama,
                      isSelected: _provider.selectedCategory?.id == cat.id,
                      onTap: () => _provider.setCategory(cat),
                    ),
                  ),
                ),
                // ── Sort button ──
              ],
            ),
          );
  }

  Widget _buildSortButton() {
    final hasSort = _provider.sortOrder != null;
    return GestureDetector(
      onTap: _showSortSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasSort ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasSort ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 16,
              color: hasSort ? AppColors.onPrimary : AppColors.onSurface,
            ),
            const SizedBox(width: 5),
            Text(
              hasSort
                  ? (_provider.sortOrder == 'asc' ? 'Termurah' : 'Termahal')
                  : 'Urutkan',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: hasSort ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Handle ──
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Urutkan Berdasarkan Harga',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SortOption(
                      label: 'Default',
                      subtitle: 'Tanpa pengurutan khusus',
                      isSelected: _provider.sortOrder == null,
                      onTap: () {
                        _provider.setSortOrder(null);
                        Navigator.pop(ctx);
                      },
                    ),
                    const SizedBox(height: 8),
                    _SortOption(
                      label: 'Termurah',
                      subtitle: 'Harga dari terendah ke tertinggi',
                      icon: Icons.arrow_upward_rounded,
                      isSelected: _provider.sortOrder == 'asc',
                      onTap: () {
                        _provider.setSortOrder('asc');
                        Navigator.pop(ctx);
                      },
                    ),
                    const SizedBox(height: 8),
                    _SortOption(
                      label: 'Termahal',
                      subtitle: 'Harga dari tertinggi ke terendah',
                      icon: Icons.arrow_downward_rounded,
                      isSelected: _provider.sortOrder == 'desc',
                      onTap: () {
                        _provider.setSortOrder('desc');
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────
  Widget _buildBody() {
    if (_provider.isLoading) {
      return _buildSkeletonGrid();
    }

    if (_provider.errorMessage != null) {
      return _buildError();
    }

    if (_provider.products.isEmpty) {
      return _buildEmpty();
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _provider.loadProducts,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = _provider.products[index];
                  return _MarketProductCard(
                    product: product,
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.productDetail,
                        pathParameters: {'id': product.id},
                      );
                    },
                  );
                }, childCount: _provider.products.length),
              ),
            ),
            if (_provider.totalPages > 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildPaginationBar(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  Widget _buildPaginationBar() {
    final current = _provider.currentPage;
    final total = _provider.totalPages;

    // Generate page numbers with ellipsis logic
    final pages = _buildPageNumbers(current, total);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Prev button ──
          _PaginationArrow(
            icon: Icons.chevron_left_rounded,
            enabled: current > 1,
            onTap: () => _provider.goToPage(current - 1),
          ),

          const SizedBox(width: 6),

          // ── Page buttons ──
          ...pages.map((p) {
            if (p == -1) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '…',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _PaginationPage(
                page: p,
                isActive: p == current,
                onTap: () => _provider.goToPage(p),
              ),
            );
          }),

          const SizedBox(width: 6),

          // ── Next button ──
          _PaginationArrow(
            icon: Icons.chevron_right_rounded,
            enabled: current < total,
            onTap: () => _provider.goToPage(current + 1),
          ),
        ],
      ),
    );
  }

  /// Generates a compact page list with ellipsis, e.g. [1, 2, -1, 7, 8, 9, -1, 20]
  List<int> _buildPageNumbers(int current, int total) {
    if (total <= 7) {
      return List.generate(total, (i) => i + 1);
    }

    final result = <int>[];
    result.add(1);

    if (current > 3) result.add(-1); // ellipsis

    final start = (current - 1).clamp(2, total - 1);
    final end = (current + 1).clamp(2, total - 1);

    for (int i = start; i <= end; i++) {
      result.add(i);
    }

    if (current < total - 2) result.add(-1); // ellipsis

    result.add(total);

    return result;
  }

  // ────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _provider.errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _provider.loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const _SkeletonProductCard(),
    );
  }

  Widget _buildEmpty() {
    final hasSearch =
        _provider.searchQuery != null && _provider.searchQuery!.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch ? Icons.search_off_rounded : Icons.grass_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasSearch ? 'Barang Tidak Ditemukan' : 'Belum Ada Produk',
              style: GoogleFonts.beVietnamPro(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Kami tidak dapat menemukan produk "${_provider.searchQuery}" yang kamu cari.'
                  : (_provider.selectedCategory == null
                        ? 'Saat ini belum ada produk yang dijual di pasar.'
                        : 'Belum ada produk di kategori ini.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Category chip widget
// ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Pagination widgets
// ────────────────────────────────────────────────────────────
class _PaginationPage extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PaginationPage({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: GoogleFonts.beVietnamPro(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PaginationArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? AppColors.primary
              : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Skeleton shimmer widgets
// ────────────────────────────────────────────────────────────
class _SkeletonProductCard extends StatefulWidget {
  const _SkeletonProductCard();

  @override
  State<_SkeletonProductCard> createState() => _SkeletonProductCardState();
}

class _SkeletonProductCardState extends State<_SkeletonProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          AppColors.surfaceContainerLow,
          AppColors.surfaceContainerHighest,
          _anim.value,
        )!;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image placeholder
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(color: shimmerColor),
                ),
              ),

              // info placeholder
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 60, height: 10, color: shimmerColor),
                      const SizedBox(height: 6),
                      _SkeletonBox(
                        width: double.infinity,
                        height: 13,
                        color: shimmerColor,
                      ),
                      const SizedBox(height: 4),
                      _SkeletonBox(width: 80, height: 13, color: shimmerColor),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SkeletonBox(
                            width: 64,
                            height: 16,
                            color: shimmerColor,
                          ),
                          _SkeletonBox(
                            width: 30,
                            height: 30,
                            radius: 8,
                            color: shimmerColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Product card (lazy-safe since it's inside GridView.builder)
// ────────────────────────────────────────────────────────────
class _MarketProductCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onTap;

  const _MarketProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildProductImage(),
                    if (product.badge != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.badge!,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Product Info ──
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.farmName,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.productName,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.priceFormatted,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (product.tipeStok != null &&
                                  product.tipeStok!.isNotEmpty)
                                Text(
                                  '/${product.tipeStok}',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_basket_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildProductImage() {
    final image = product.image;

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Icon(Icons.eco_rounded, size: 40, color: AppColors.outline),
    );
  }
}

// ── Sort option tile ──────────────────────────────────
class _SortOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.subtitle,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.list_rounded,
                  size: 16,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
