import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tandur/core/constants/color.dart';

class FullScreenMapScreen extends StatelessWidget {
  final LatLng location;
  final String title;

  const FullScreenMapScreen({
    super.key,
    required this.location,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lokasi $title",
          style: GoogleFonts.beVietnamPro(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: location, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId('farmer_location_fullscreen'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(title: title),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapToolbarEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
