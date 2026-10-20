import 'package:flutter/material.dart';

import '../../app/theme/mass_colors.dart';

enum MassNoticeTone { error, info }

class MassNotice extends StatelessWidget {
  const MassNotice({
    required this.message,
    this.title,
    this.tone = MassNoticeTone.error,
    super.key,
  });

  final String message;
  final String? title;
  final MassNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final isError = tone == MassNoticeTone.error;
    final background = isError
        ? MassColors.dangerContainer
        : MassColors.surfaceLow;
    final foreground = isError ? MassColors.onDanger : MassColors.ink;
    final icon = isError ? Icons.error_outline : Icons.info_outline;

    return Semantics(
      liveRegion: isError,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MassColors.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(message, style: TextStyle(color: foreground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
