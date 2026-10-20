import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../application/order_providers.dart';
import '../domain/order_status.dart';
import 'order_widgets.dart';

class AdminSummaryScreen extends ConsumerWidget {
  const AdminSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(adminHomeProvider);
    return home.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(adminHomeProvider),
      ),
      data: (data) {
        final entries = data.summary.countsByStatus.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const MassSectionTitle(
              title: 'Resumen operativo',
              help: 'Revisa cuántos pedidos hay en cada estado y los contactos registrados.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CountTile(
                  icon: Icons.receipt_long,
                  label: 'Registrados',
                  value: data.summary.total,
                ),
                for (final entry in entries)
                  _CountTile(
                    icon: _statusIcon(entry.key),
                    label: _label(entry.key),
                    value: entry.value,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Contactos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (data.contacts.isEmpty)
              const Text(
                'Todavía no hay contactos registrados.',
                style: TextStyle(color: MassColors.muted),
              ),
            for (final contact in data.contacts)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: MassColors.yellow,
                    foregroundColor: MassColors.ink,
                    child: Text(_initial(contact.name)),
                  ),
                  title: Text(contact.name),
                  subtitle: Text(
                    contact.phone.isEmpty ? 'Sin teléfono' : contact.phone,
                  ),
                  trailing: Text(
                    '${contact.orderCount}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

String _label(String storage) {
  try {
    return orderStatusLabel(orderStatusFromStorage(storage));
  } on FormatException {
    return storage;
  }
}

IconData _statusIcon(String storage) {
  return switch (storage) {
    'submitted' => Icons.inbox,
    'preparing' => Icons.soup_kitchen,
    'ready_for_pickup' => Icons.storefront,
    'ready_for_dispatch' => Icons.inventory,
    'assigned' => Icons.assignment_ind,
    'in_delivery' => Icons.local_shipping,
    'delivered' => Icons.where_to_vote,
    'completed' => Icons.check_circle,
    'cancelled' => Icons.cancel,
    'delivery_failed' => Icons.error_outline,
    _ => Icons.circle,
  };
}

String _initial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.substring(0, 1).toUpperCase();
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: MassColors.ink),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: MassColors.ink,
                ),
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: MassColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
