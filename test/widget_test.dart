import 'package:app_mass/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'la aplicación sin configuración permanece fuera de las rutas internas',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MassApp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Configuración requerida'), findsOneWidget);
    },
  );
}
