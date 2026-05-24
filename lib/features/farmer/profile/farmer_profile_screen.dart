// Farmer profile screen — re-exports the shared implementation.
// This file exists to preserve the existing route/import structure.
export 'package:tandur/core/widgets/shared_profile_screen.dart'
    show SharedProfileScreen;

import 'package:flutter/material.dart';
import 'package:tandur/core/widgets/shared_profile_screen.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const SharedProfileScreen();
}
