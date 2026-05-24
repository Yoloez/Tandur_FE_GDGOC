import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({
    super.key,
    this.initialLocation = const LatLng(-6.200000, 106.816666), // Default to Jakarta
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLocation;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _getAddressFromLatLng(_selectedLocation);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.subLocality}, ${place.locality}';
        setState(() {
          _searchController.text = address;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLatLng = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selectedLocation = newLatLng;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 15));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi tidak ditemukan')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromLatLng(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Lokasi',
          style: GoogleFonts.inter(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTapped,
            markers: {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchAddress,
                decoration: InputDecoration(
                  hintText: 'Cari lokasi (cth: Monas)',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                  suffixIcon: _isLoading 
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.outline),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          // Confirm Button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'location': _selectedLocation,
                  'address': _searchController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                'Konfirmasi Lokasi',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
