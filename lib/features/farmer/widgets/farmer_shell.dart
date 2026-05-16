import 'package:flutter/material.dart';
import 'farmer_bottom_nav.dart';

/// Shell wrapper for farmer section — provides the bottom navigation bar.
class FarmerShell extends StatelessWidget {
  final String location;
  final Widget child;

  const FarmerShell({
    super.key,
    required this.location,
    required this.child,
  });

  int _locationToIndex() {
    if (location.startsWith('/farmer/market')) return 1;
    if (location.startsWith('/farmer/notifications')) return 2;
    if (location.startsWith('/farmer/profile')) return 3;
    return 0; // /farmer/home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: FarmerBottomNav(currentIndex: _locationToIndex()),
    );
  }
}
