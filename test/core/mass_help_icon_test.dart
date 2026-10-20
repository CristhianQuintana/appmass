import 'package:app_mass/core/widgets/mass_help_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el icono de ayuda muestra la indicación al tocarlo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MassHelpIcon(
            message: 'Selecciona los productos que formarán parte del pedido.',
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Ayuda'));
    await tester.pumpAndSettle();

    expect(
      find.text('Selecciona los productos que formarán parte del pedido.'),
      findsOneWidget,
    );
    expect(find.text('Entendido'), findsOneWidget);
  });
}
