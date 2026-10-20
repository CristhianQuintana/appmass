import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/domain/staff_role.dart';
import '../application/order_providers.dart';
import '../domain/store_order.dart';
import 'order_widgets.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(staffListProvider);
    final selfId = ref.watch(profileControllerProvider).asData?.value?.id;
    return staff.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(staffListProvider),
      ),
      data: (members) {
        if (members.isEmpty) {
          return const Center(child: Text('No hay personal para mostrar.'));
        }
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: MassSectionTitle(
                title: 'Personal',
                help: 'Selecciona a una persona para cambiar su rol o su acceso. No puedes modificar tu propia cuenta.',
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final own = member.id == selfId;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: MassColors.yellow,
                        foregroundColor: MassColors.ink,
                        child: Text(
                          (member.fullName.trim().isEmpty
                                  ? '?'
                                  : member.fullName.trim().substring(0, 1))
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(
                        member.fullName.isEmpty
                            ? 'Sin nombre'
                            : member.fullName,
                      ),
                      subtitle: Text(
                        '${_roleLabel(member.role)} · ${member.isActive ? 'activo' : 'inactivo'}'
                        '${own ? ' · tu cuenta' : ''}',
                      ),
                      trailing: own
                          ? const Icon(
                              Icons.lock_outline,
                              color: MassColors.muted,
                            )
                          : const Icon(Icons.edit_outlined),
                      onTap: own
                          ? null
                          : () async {
                              final saved = await showDialog<bool>(
                                context: context,
                                builder: (context) =>
                                    _StaffEditor(member: member),
                              );
                              if (saved == true) {
                                ref.invalidate(staffListProvider);
                              }
                            },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StaffEditor extends ConsumerStatefulWidget {
  const _StaffEditor({required this.member});

  final StaffMember member;

  @override
  ConsumerState<_StaffEditor> createState() => _StaffEditorState();
}

class _StaffEditorState extends ConsumerState<_StaffEditor> {
  late final TextEditingController _name;
  late String _role;
  late bool _active;
  String? _message;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.member.fullName);
    _role = widget.member.role;
    _active = widget.member.isActive;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Acceso del personal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Rol'),
            items: const [
              DropdownMenuItem(
                value: 'administrator',
                child: Text('Administrador'),
              ),
              DropdownMenuItem(value: 'operator', child: Text('Operador')),
              DropdownMenuItem(value: 'courier', child: Text('Transportista')),
              DropdownMenuItem(
                value: 'unassigned',
                child: Text('Sin rol operativo'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _role = value);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cuenta activa'),
            value: _active,
            onChanged: (value) => setState(() => _active = value),
          ),
          const Text(
            'Desactivar la cuenta no cierra una sesión ya emitida. También hay que bloquear el usuario en Auth.',
            style: TextStyle(color: MassColors.muted, fontSize: 12),
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            MassNotice(message: _message!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Guardando' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _name.text.trim().length > 120) {
      setState(() => _message = 'Ingresa un nombre válido.');
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref
          .read(orderRepositoryProvider)
          .setStaffAccess(
            userId: widget.member.id,
            role: _role,
            active: _active,
            fullName: _name.text,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _message = userFacingMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

String _roleLabel(String role) => StaffRole.fromStorage(role).label;
