import 'package:flutter/material.dart';

import '../../app/theme/mass_colors.dart';

/// Icono breve de ayuda. Al tocarlo muestra una sola indicación.
class MassHelpIcon extends StatelessWidget {
  const MassHelpIcon({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Ayuda',
      style: IconButton.styleFrom(
        foregroundColor: MassColors.muted,
        minimumSize: const Size(48, 48),
      ),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ayuda'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.info_outline),
    );
  }
}

class MassSectionTitle extends StatelessWidget {
  const MassSectionTitle({required this.title, required this.help, super.key});

  final String title;
  final String help;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: MassColors.ink,
            ),
          ),
        ),
        MassHelpIcon(message: help),
      ],
    );
  }
}
