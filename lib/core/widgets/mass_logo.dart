import 'package:flutter/material.dart';

import '../../app/theme/mass_colors.dart';

/// Marca MASS para la barra superior del cliente.
class MassLogo extends StatelessWidget {
  const MassLogo({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 28.0 : 34.0;
    return Semantics(
      label: 'MASS',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MassColors.yellow,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: MassColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'M',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: height * 0.55,
                color: MassColors.ink,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'MASS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: compact ? 20 : 22,
              letterSpacing: 1.2,
              color: MassColors.ink,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
