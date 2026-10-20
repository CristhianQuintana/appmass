import 'package:flutter/material.dart';

import '../../app/theme/mass_colors.dart';

class MassWordmark extends StatelessWidget {
  const MassWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MASS',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: MassColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MassColors.outline),
        ),
        child: const Text(
          'MASS',
          style: TextStyle(
            color: MassColors.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
