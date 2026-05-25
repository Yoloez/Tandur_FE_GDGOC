import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/features/buyer/cart/providers/cart_provider.dart';

/// Top bar: location pin + text | brand name | search icon
class BuyerAppBar extends StatefulWidget {
  final String location;

  const BuyerAppBar({super.key, required this.location});

  @override
  State<BuyerAppBar> createState() => _BuyerAppBarState();
}

class _BuyerAppBarState extends State<BuyerAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    if (value.trim().isEmpty) return;
    // Go to buyer market and pass the search query
    context.goNamed(
      AppRoutes.buyerMarket,
      queryParameters: {'q': value.trim()},
    );
    // Optionally close search mode
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // If searching, we hide the logo and brand to give more space
          if (!_isSearching) ...[
            Image.asset(
              'assets/images/tandur-logo-no-bg.png',
              width: 45,
              height: 45,
            ),
            const SizedBox(width: 6),
            Text(
              'Tandur',
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
          ],

          // ── Search Field / Icon ──
          Expanded(
            flex: _isSearching ? 1 : 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSearching ? double.infinity : 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(_isSearching ? 12 : 18),
                border: Border.all(
                  color: _isSearching
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: _isSearching
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _submitSearch,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Cari produk...',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.onSurfaceVariant,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                        _focusNode.requestFocus();
                      },
                      child: const Center(
                        child: Icon(
                          Icons.search_rounded,
                          color: AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          ListenableBuilder(
            listenable: CartProvider.instance,
            builder: (context, child) {
              final totalItems = CartProvider.instance.totalItems;
              return GestureDetector(
                onTap: () {
                  context.pushNamed(AppRoutes.buyerCart);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.onSurface,
                        size: 20,
                      ),
                      if (totalItems > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              totalItems.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
