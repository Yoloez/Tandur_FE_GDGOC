import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'farmer_bottom_nav.dart';

/// Shell wrapper for farmer section — provides the bottom navigation bar.
class FarmerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const FarmerShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: FarmerBottomNav(navigationShell: navigationShell),
    );
  }
}
