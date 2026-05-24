import 'package:flutter/material.dart';
import 'package:tandur/features/buyer/widgets/app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  int _locationToIndex() {
    if (location.startsWith('/buyer/profile')) {
      return 3;
    }
    if (location.startsWith('/buyer/market')) {
      return 1;
    }
    if (location.startsWith('/buyer/home')) {
      return 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(currentIndex: _locationToIndex()),
    );
  }
}
