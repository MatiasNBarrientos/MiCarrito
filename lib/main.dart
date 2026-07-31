import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/screens/pantalla_principal.dart';

// --- EL MEGÁFONO GLOBAL PARA EL TEMA ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  // Aseguramos que Flutter esté listo antes de leer la memoria
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  // Leemos la memoria del celular para ver si habías guardado un tema
  final prefs = await SharedPreferences.getInstance();
  final temaGuardado = prefs.getString('tema_app');

  if (temaGuardado == 'claro') {
    themeNotifier.value = ThemeMode.light;
  } else if (temaGuardado == 'oscuro') {
    themeNotifier.value = ThemeMode.dark;
  }

  runApp(const MiCarritoApp());
}

class MiCarritoApp extends StatelessWidget {
  const MiCarritoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha al megáfono y redibuja la app si cambia el tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode modoActual, _) {
        return MaterialApp(
          title: 'MiCarrito',
          debugShowCheckedModeBanner: false,
          themeMode: modoActual,

          // --- TEMA CLARO ---
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFD49EEB),
            scaffoldBackgroundColor: Colors.grey.shade100,
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFD49EEB),
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD49EEB),
              secondary: Colors.cyanAccent,
            ),
          ),

          // --- TEMA OSCURO ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFFD49EEB),
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD49EEB),
              secondary: Colors.cyanAccent,
            ),
          ),

          home: const PantallaPrincipal(),
        );
      },
    );
  }
}
