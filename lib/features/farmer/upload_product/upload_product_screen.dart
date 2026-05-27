import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:tandur/core/utils/image_picker_helper.dart';
import 'package:tandur/features/farmer/upload_product/models/price_analysis_result.dart';
import 'package:tandur/features/farmer/upload_product/providers/upload_product_provider.dart';

/// Full-page form for adding a new farmer product.
///
/// Currently a local form. To integrate with API, call:
/// ```dart
/// final formData = FormData.fromMap({
///   'name': _nameController.text,
///   'category': _selectedCategory,
///   'description': _descController.text,
///   'price': int.parse(_priceController.text),
///   'stock': int.parse(_stockController.text),
///   'stock_unit': _selectedUnit,
///   'images': [for (final f in _images) await MultipartFile.fromFile(f.path)],
/// });
/// await dio.post('/api/farmer/products', data: formData);
/// ```
class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  final _provider = UploadProductProvider.instance;
  final List<File> _selectedImages = [];

  String _selectedUnit = 'kg';

  static const _units = ['kg', 'ikat', 'pack', 'buah', 'liter'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _onPickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Kamera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeri'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final file = await ImagePickerHelper.pickImage(source: source);
    if (!mounted) return;

    if (file != null) {
      setState(() => _selectedImages.add(file));
    }
  }

  Future<void> _onAnalyzePrice() async {
    if (_selectedImages.isEmpty) {
      _showError('Upload foto produk terlebih dahulu.');
      return;
    }
    final result = await _provider.analyzePrice(
      images: _selectedImages,
      productName: _nameController.text.trim(),
    );
    if (!mounted) return;
    if (result != null) {
      _showPriceAnalysisSheet(result);
    } else {
      _showError(_provider.errorMessage ?? 'Gagal menganalisis harga.');
    }
  }

  Future<void> _onGenerateAI() async {
    final namaProduk = _nameController.text.trim();
    if (namaProduk.isEmpty) {
      _showError('Isi nama produk terlebih dahulu.');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showError('Upload foto produk terlebih dahulu.');
      return;
    }
    if (_provider.selectedCategory == null) {
      _showError('Pilih kategori produk terlebih dahulu.');
      return;
    }

    final desc = await _provider.generateAiDescription(
      photo: _selectedImages.first,
      namaProduk: namaProduk,
    );

    if (!mounted) return;

    if (desc != null) {
      _descController.text = desc;
    } else {
      _showError(_provider.errorMessage ?? 'Gagal generate deskripsi AI.');
    }
  }

  void _onSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Produk disimpan sebagai draft.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _onPublish() async {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final stock = int.tryParse(_stockController.text.trim());
    final price = int.tryParse(_priceController.text.trim());

    if (name.isEmpty) {
      _showError('Nama produk wajib diisi.');
      return;
    }
    if (stock == null || stock <= 0) {
      _showError('Stok harus diisi dengan angka valid.');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showError('Foto produk wajib diunggah.');
      return;
    }
    if (_provider.selectedCategory == null) {
      _showError('Pilih kategori produk.');
      return;
    }

    final success = await _provider.submitProduct(
      namaProduk: name,
      deskripsi: description,
      stok: stock,
      tipeStok: _selectedUnit,
      photos: _selectedImages,
      harga: price,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produk berhasil disimpan!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      _showError(_provider.errorMessage ?? 'Gagal menyimpan produk.');
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
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Produk Baru',
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo upload ──
            _buildPhotoSection(),

            const SizedBox(height: 24),

            // ── Nama Produk ──
            _buildLabel('Nama Produk'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Misal: Tomat Ceri Organik',
            ),

            const SizedBox(height: 20),

            // ── Kategori ──
            _buildLabel('Kategori'),
            const SizedBox(height: 10),
            _buildCategoryChips(),

            const SizedBox(height: 20),

            // ── Deskripsi ──
            _buildDescriptionHeader(),
            const SizedBox(height: 8),
            _buildDescriptionField(),

            const SizedBox(height: 20),

            // ── Harga Satuan ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Harga Satuan'),
                ListenableBuilder(
                  listenable: _provider,
                  builder: (context, _) {
                    final busy = _provider.isAnalyzingPrice;
                    return GestureDetector(
                      onTap: busy ? null : _onAnalyzePrice,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: busy
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryContainer,
                                  ],
                                ),
                          color: busy
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (busy)
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            else
                              const Icon(Icons.auto_awesome,
                                  size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              busy ? 'Menganalisis...' : 'Analisis AI Harga',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: busy
                                    ? AppColors.primary
                                    : Colors.white,
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
            const SizedBox(height: 8),
            _buildPriceField(),

            const SizedBox(height: 20),

            // ── Stok ──
            _buildLabel('Stok Tersedia'),
            const SizedBox(height: 8),
            _buildStockField(),

            const SizedBox(height: 24),

            // ── Verification info ──
            _buildVerificationCard(),

            const SizedBox(height: 100), // space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Photo upload section
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header with AI tip ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UPLOAD FOTO\nPRODUK',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: 0.8,
                height: 1.4,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'AI Tip: Gunakan cahaya\nalami',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Upload area ──
        GestureDetector(
          onTap: _onPickPhoto,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ketuk untuk Ambil Foto',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maksimal 5 foto • JPG, PNG',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_selectedImages.first, fit: BoxFit.cover),
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                          child: Text(
                            '${_selectedImages.length} foto dipilih • Ketuk untuk tambah',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Category chips
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCategoryChips() {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        if (_provider.isLoadingCategories) {
          return const SizedBox(
            height: 36,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        final categories = _provider.categories;
        if (categories.isEmpty) {
          return GestureDetector(
            onTap: _provider.loadCategories,
            child: Text(
              'Gagal memuat kategori. Ketuk untuk retry.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _provider.selectedCategory?.id == cat.id;
            return GestureDetector(
              onTap: () => _provider.setSelectedCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                  ),
                ),
                child: Text(
                  cat.nama,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Description header with AI button
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDescriptionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLabel('Deskripsi Produk'),
        ListenableBuilder(
          listenable: _provider,
          builder: (context, _) {
            final isLoading = _provider.isGeneratingAi;
            return GestureDetector(
              onTap: isLoading ? null : _onGenerateAI,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      isLoading ? 'Membuat deskripsi...' : 'Gunakan AI',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descController,
      maxLines: 4,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Ceritakan kesegaran panen Anda...',
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Price field with Rp prefix
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPriceField() {
    return TextField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
        prefixText: 'Rp  ',
        prefixStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Stock field with unit dropdown
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildStockField() {
    return Row(
      children: [
        // ── Quantity input ──
        Expanded(
          child: TextField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ── Unit dropdown ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
              items: _units
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedUnit = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Verification info card
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi Keaslian',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Produk Anda akan tampil dengan label "Terverifikasi" setelah tim kami meninjau kesesuaian foto.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Bottom action bar
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBottomBar() {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final isSubmitting = _provider.isSubmitting;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // ── Draft button ──
                OutlinedButton(
                  onPressed: isSubmitting ? null : _onSaveDraft,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Draft',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ── Publish button ──
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _onPublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Simpan Produk',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Shared helpers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Category is now handled via API (kategoriId from provider)

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // AI Price Analysis Bottom Sheet
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _showPriceAnalysisSheet(PriceAnalysisResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PriceAnalysisSheet(
        result: result,
        onApplyPrice: (price) {
          _priceController.text = price.toString();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Price Analysis Result Sheet
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PriceAnalysisSheet extends StatelessWidget {
  final PriceAnalysisResult result;
  final void Function(int price) onApplyPrice;

  const _PriceAnalysisSheet({
    required this.result,
    required this.onApplyPrice,
  });

  String _formatRp(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  Color _gradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return AppColors.success;
      case 'B':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = result.quality;
    final ep = result.estimatedPrice;
    final rec = result.recommendation;
    final va = result.visualAnalysis;
    final confidencePct = (result.confidenceScore * 100).round();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Analisis AI',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        result.productDetected,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Confidence badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$confidencePct% akurat',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Estimated Price Card ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimasi Harga Pasar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_formatRp(ep.min)} – ${_formatRp(ep.max)}',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Text('📦',
                          style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Harga Rekomendasi: ${_formatRp(rec.recommendedPrice)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Quality row ──
            Row(
              children: [
                // Grade badge
                Expanded(
                  child: _InfoCard(
                    icon: Icons.grade_rounded,
                    label: 'Grade',
                    value: q.grade,
                    valueColor: _gradeColor(q.grade),
                    valueFontSize: 26,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Skor Kualitas',
                    value: '${q.score}/100',
                    valueColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.local_offer_rounded,
                    label: 'Kategori',
                    value: rec.sellingCategory,
                    valueColor: AppColors.accent,
                    valueFontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.water_drop_rounded,
                    label: 'Kesegaran',
                    value: q.freshness,
                    valueColor: AppColors.info,
                    valueFontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.energy_savings_leaf_rounded,
                    label: 'Kematangan',
                    value: q.ripeness,
                    valueColor: AppColors.success,
                    valueFontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Kondisi',
                    value: q.condition,
                    valueColor: AppColors.primary,
                    valueFontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Visual Analysis ──
            _SectionTitle(title: 'Analisis Visual'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  _VisualRow(label: 'Warna', value: va.color),
                  _VisualRow(label: 'Permukaan', value: va.surfaceCondition),
                  _VisualRow(label: 'Bentuk', value: va.shapeConsistency),
                  _VisualBoolRow(label: 'Kerusakan', detected: va.damageDetected),
                  _VisualBoolRow(label: 'Jamur', detected: va.moldDetected),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Reasoning ──
            _SectionTitle(title: 'Alasan AI'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: result.reasoning
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                r,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Apply button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () =>
                    onApplyPrice(rec.recommendedPrice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.price_check_rounded, size: 20),
                label: Text(
                  'Gunakan Harga ${_formatRp(rec.recommendedPrice)}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final double valueFontSize;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueFontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.beVietnamPro(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _VisualRow extends StatelessWidget {
  final String label;
  final String value;
  const _VisualRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualBoolRow extends StatelessWidget {
  final String label;
  final bool detected;
  const _VisualBoolRow({required this.label, required this.detected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Icon(
            detected ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            size: 16,
            color: detected ? AppColors.error : AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            detected ? 'Terdeteksi' : 'Tidak Terdeteksi',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: detected ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

