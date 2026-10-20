import 'package:flutter/material.dart';

import '../../app/theme/mass_colors.dart';

class MassLoading extends StatelessWidget {
  const MassLoading({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: MassColors.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
