import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_redirect.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/session_status.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/order_draft.dart';
import '../../orders/domain/order_status.dart';
import '../../orders/presentation/order_widgets.dart';
import '../../profile/application/profile_controller.dart';
import '../application/customer_cart.dart';

class CustomerCartScreen extends ConsumerStatefulWidget {
  const CustomerCartScreen({this.asDrawer = false, super.key});

  final bool asDrawer;

  @override
  ConsumerState<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends ConsumerState<CustomerCartScreen> {
  static const _departments = [
    'Lima',
    'Arequipa',
    'Cusco',
    'La Libertad',
    'Piura',
    'Lambayeque',
    'Junín',
    'Áncash',
    'Ica',
    'Otro',
  ];

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _document;
  late final TextEditingController _email;
  late final TextEditingController _province;
  late final TextEditingController _district;
  late final TextEditingController _street;
  late final TextEditingController _reference;
  late final TextEditingController _notes;
  var _department = 'Lima';
  var _modality = OrderModality.delivery;
  var _step = 0;
  var _submitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).asData?.value;
    _name = TextEditingController(text: profile?.displayName ?? '');
    _phone = TextEditingController();
    _document = TextEditingController();
    _email = TextEditingController();
    _province = TextEditingController(text: 'Lima');
    _district = TextEditingController();
    _street = TextEditingController();
    _reference = TextEditingController();
    _notes = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _document.dispose();
    _email.dispose();
    _province.dispose();
    _district.dispose();
    _street.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(customerCartProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CartHeader(
          asDrawer: widget.asDrawer,
          step: _step,
          quantity: cart.quantity,
          onClose: () => Navigator.of(context).maybePop(),
          onBackStep: _step > 0 ? () => setState(() => _step -= 1) : null,
        ),
        Expanded(
          child: cart.lines.isEmpty
              ? const _EmptyCart()
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _step == 0
                        ? _CartLinesStep(
                            cart: cart,
                            onContinue: () {
                              final session = ref.read(sessionControllerProvider);
                              if (session.status != SessionStatus.signedIn) {
                                if (widget.asDrawer) {
                                  Navigator.of(context).maybePop();
                                }
                                context.go(
                                  loginWithNext(
                                    '${AppRoutes.customerHome}?checkout=1',
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _message = null;
                                _step = 1;
                              });
                            },
                            onChange: (id, qty) => ref
                                .read(customerCartProvider.notifier)
                                .change(id, qty),
                          )
                        : _CheckoutFormStep(
                            modality: _modality,
                            department: _department,
                            departments: _departments,
                            name: _name,
                            phone: _phone,
                            document: _document,
                            email: _email,
                            province: _province,
                            district: _district,
                            street: _street,
                            reference: _reference,
                            notes: _notes,
                            message: _message,
                            submitting: _submitting,
                            totalCents: cart.totalCents,
                            onModality: (value) =>
                                setState(() => _modality = value),
                            onDepartment: (value) =>
                                setState(() => _department = value),
                            onSubmit: _confirm,
                          ),
                  ),
                ),
        ),
      ],
    );
  }

  String? _validateFormFields() {
    if (_name.text.trim().length < 3) {
      return 'Ingresa el nombre completo del destinatario.';
    }
    final phone = _phone.text.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (phone.length < 9 || !RegExp(r'^\+?\d+$').hasMatch(phone)) {
      return 'Ingresa un celular válido.';
    }
    final doc = _document.text.trim();
    if (doc.length < 8 || doc.length > 12) {
      return 'Ingresa tu DNI o documento (8 a 12 caracteres).';
    }
    final email = _email.text.trim();
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Revisa el correo electrónico.';
    }
    if (_modality == OrderModality.delivery) {
      if (_district.text.trim().length < 2) {
        return 'Ingresa el distrito.';
      }
      if (_province.text.trim().length < 2) {
        return 'Ingresa la provincia.';
      }
      if (_street.text.trim().length < 5) {
        return 'Ingresa la calle, número o urbanización.';
      }
    }
    return null;
  }

  OrderDraft _composeDraft(CustomerCart cart) {
    final address = _modality == OrderModality.delivery
        ? [
            _street.text.trim(),
            _district.text.trim(),
            _province.text.trim(),
            _department,
          ].where((part) => part.isNotEmpty).join(', ')
        : 'Recojo en tienda';
    final notes = [
      'Doc: ${_document.text.trim()}',
      if (_email.text.trim().isNotEmpty) 'Email: ${_email.text.trim()}',
      if (_notes.text.trim().isNotEmpty) _notes.text.trim(),
    ].join(' | ');
    return OrderDraft(
      customerName: _name.text.trim(),
      customerPhone: _phone.text.trim().replaceAll(RegExp(r'[\s-]'), ''),
      addressLine: address,
      addressReference: _modality == OrderModality.delivery
          ? _reference.text.trim()
          : 'Recojo en tienda',
      notes: notes,
      modality: _modality,
      lines: cart.lines,
      idempotencyKey: cart.idempotencyKey,
    );
  }

  Future<void> _confirm() async {
    final session = ref.read(sessionControllerProvider);
    if (session.status != SessionStatus.signedIn) {
      if (widget.asDrawer) {
        Navigator.of(context).maybePop();
      }
      context.go(
        loginWithNext('${AppRoutes.customerHome}?checkout=1'),
      );
      return;
    }
    final formError = _validateFormFields();
    if (formError != null) {
      setState(() => _message = formError);
      return;
    }
    final cart = ref.read(customerCartProvider);
    final draft = _composeDraft(cart);
    final validation = draft.validateCustomerCheckout();
    if (validation != null) {
      setState(() => _message = validation);
      return;
    }
    setState(() {
      _submitting = true;
      _message = null;
    });
    try {
      final id = await ref.read(orderRepositoryProvider).createOrder(draft);
      ref.read(customerCartProvider.notifier).clear();
      ref.invalidate(ordersListProvider);
      if (!mounted) return;
      if (widget.asDrawer) {
        Navigator.of(context).maybePop();
      }
      context.go('${AppRoutes.customerHome}/pedido/$id');
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = userFacingMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({
    required this.asDrawer,
    required this.step,
    required this.quantity,
    required this.onClose,
    required this.onBackStep,
  });

  final bool asDrawer;
  final int step;
  final int quantity;
  final VoidCallback onClose;
  final VoidCallback? onBackStep;

  @override
  Widget build(BuildContext context) {
    final title = step == 0 ? 'Carrito' : 'Datos de entrega';
    return Material(
      color: MassColors.yellow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
        child: Row(
          children: [
            IconButton(
              tooltip: onBackStep != null
                  ? 'Volver'
                  : (asDrawer ? 'Cerrar' : 'Cerrar'),
              onPressed: onBackStep ?? (asDrawer ? onClose : null),
              icon: Icon(onBackStep != null ? Icons.arrow_back : Icons.close),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: MassColors.ink,
                    ),
                  ),
                  Text(
                    step == 0
                        ? (quantity == 0
                              ? 'Sin productos'
                              : '$quantity producto${quantity == 1 ? '' : 's'}')
                        : 'Paso 2 de 2',
                    style: const TextStyle(
                      fontSize: 12,
                      color: MassColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (asDrawer && onBackStep != null)
              IconButton(
                tooltip: 'Cerrar',
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: MassColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: MassColors.ink,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Explora el catálogo y agrega los productos que necesitas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MassColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLinesStep extends StatelessWidget {
  const _CartLinesStep({
    required this.cart,
    required this.onContinue,
    required this.onChange,
  });

  final CustomerCart cart;
  final VoidCallback onContinue;
  final void Function(String productId, int quantity) onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: cart.lines.length,
            itemBuilder: (context, index) {
              final line = cart.lines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductArtwork(
                        label: line.product.category,
                        imageUrl: line.product.imageUrl,
                        size: 72,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: MassColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              line.product.unitLabel,
                              style: const TextStyle(
                                color: MassColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onPressed: () =>
                                      onChange(line.product.id, line.quantity - 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    '${line.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onPressed: () =>
                                      onChange(line.product.id, line.quantity + 1),
                                ),
                                const Spacer(),
                                MoneyText(line.lineTotalCents),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Material(
          elevation: 8,
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: MassColors.muted,
                        ),
                      ),
                      const Spacer(),
                      MoneyText(cart.totalCents, emphasize: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MassButton(
                    label: 'Continuar al pedido',
                    icon: Icons.arrow_forward,
                    onPressed: onContinue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: MassColors.ink),
        ),
      ),
    );
  }
}

class _CheckoutFormStep extends StatelessWidget {
  const _CheckoutFormStep({
    required this.modality,
    required this.department,
    required this.departments,
    required this.name,
    required this.phone,
    required this.document,
    required this.email,
    required this.province,
    required this.district,
    required this.street,
    required this.reference,
    required this.notes,
    required this.message,
    required this.submitting,
    required this.totalCents,
    required this.onModality,
    required this.onDepartment,
    required this.onSubmit,
  });

  final OrderModality modality;
  final String department;
  final List<String> departments;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController document;
  final TextEditingController email;
  final TextEditingController province;
  final TextEditingController district;
  final TextEditingController street;
  final TextEditingController reference;
  final TextEditingController notes;
  final String? message;
  final bool submitting;
  final int totalCents;
  final ValueChanged<OrderModality> onModality;
  final ValueChanged<String> onDepartment;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              const Text(
                '¿Cómo quieres recibir tu pedido?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: MassColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<OrderModality>(
                segments: const [
                  ButtonSegment(
                    value: OrderModality.delivery,
                    label: Text('Domicilio'),
                    icon: Icon(Icons.local_shipping_outlined),
                  ),
                  ButtonSegment(
                    value: OrderModality.inStore,
                    label: Text('Recojo'),
                    icon: Icon(Icons.storefront_outlined),
                  ),
                ],
                selected: {modality},
                onSelectionChanged: (value) => onModality(value.first),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Destinatario'),
              const SizedBox(height: 8),
              TextField(
                key: const Key('customer-name'),
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('customer-phone'),
                controller: phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Celular / WhatsApp',
                  hintText: '999 999 999',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('customer-document'),
                controller: document,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: const InputDecoration(
                  labelText: 'DNI / documento',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('customer-email'),
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              if (modality == OrderModality.delivery) ...[
                const SizedBox(height: 20),
                const _SectionLabel('Dirección de entrega'),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Departamento',
                    prefixIcon: Icon(Icons.map_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: department,
                      items: [
                        for (final item in departments)
                          DropdownMenuItem(value: item, child: Text(item)),
                      ],
                      onChanged: (value) {
                        if (value != null) onDepartment(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customer-province'),
                  controller: province,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Provincia',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customer-district'),
                  controller: district,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Distrito',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customer-address'),
                  controller: street,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Calle, número y urbanización',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customer-reference'),
                  controller: reference,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Referencia / piso / interior',
                    prefixIcon: Icon(Icons.signpost_outlined),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const _SectionLabel('Indicaciones'),
              const SizedBox(height: 8),
              TextField(
                key: const Key('customer-notes'),
                controller: notes,
                maxLength: 400,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notas para la entrega (opcional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                MassNotice(message: message!),
              ],
            ],
          ),
        ),
        Material(
          elevation: 8,
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total a pagar en tienda',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: MassColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      MoneyText(totalCents, emphasize: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'No se cobra en la aplicación.',
                    style: TextStyle(color: MassColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  MassButton(
                    buttonKey: const Key('customer-confirm'),
                    label: 'Confirmar pedido',
                    icon: Icons.check_circle_outline,
                    isLoading: submitting,
                    onPressed: onSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        color: MassColors.ink,
      ),
    );
  }
}
