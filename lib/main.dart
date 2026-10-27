import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'features/authentication/application/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Catálogo ~100 miniaturas: más capacidad en memoria para reutilizar al scroll.
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 220;
  imageCache.maximumSizeBytes = 120 << 20;
  final startup = await bootstrap();
  runApp(
    ProviderScope(
      overrides: [startupProvider.overrideWithValue(startup)],
      child: const MassApp(),
    ),
  );
}
