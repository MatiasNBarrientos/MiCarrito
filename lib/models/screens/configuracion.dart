import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // Mantenemos tu ruta hacia el main

class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({super.key});

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion> {
  bool _modoOscuroActivado = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadoDelSwitch();
  }

  void _cargarEstadoDelSwitch() {
    if (themeNotifier.value == ThemeMode.dark) {
      _modoOscuroActivado = true;
    } else if (themeNotifier.value == ThemeMode.light) {
      _modoOscuroActivado = false;
    } else {
      final brilloSistema =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _modoOscuroActivado = brilloSistema == Brightness.dark;
    }
  }

  Future<void> _cambiarTema(bool esOscuro) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _modoOscuroActivado = esOscuro);

    if (esOscuro) {
      themeNotifier.value = ThemeMode.dark;
      await prefs.setString('tema_app', 'oscuro');
    } else {
      themeNotifier.value = ThemeMode.light;
      await prefs.setString('tema_app', 'claro');
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final colorFondo = esOscuro
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);
    final colorTarjeta = esOscuro ? const Color(0xFF1E1E1E) : Colors.white;
    final colorTexto = esOscuro ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: colorFondo, // Fondo adaptable al tema
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        title: const Text(
          'Configuración',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // TÍTULO SECCIÓN
          const Text(
            'APARIENCIA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),

          // TARJETA DE MODO OSCURO MEJORADA
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: colorTarjeta,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                activeThumbColor: const Color(0xFFD49EEB),
                activeTrackColor: const Color(
                  0xFF6A1B9A,
                ).withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  'Modo Oscuro',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorTexto,
                  ),
                ),
                subtitle: Text(
                  'Forzar colores oscuros en la aplicación',
                  style: TextStyle(
                    color: esOscuro ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                value: _modoOscuroActivado,
                onChanged: _cambiarTema,
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        (_modoOscuroActivado
                                ? const Color(0xFFD49EEB)
                                : Colors.orange)
                            .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _modoOscuroActivado ? Icons.dark_mode : Icons.light_mode,
                    color: _modoOscuroActivado
                        ? const Color(0xFFD49EEB)
                        : Colors.orange,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 35),

          // TÍTULO SECCIÓN
          const Text(
            'DATOS Y SINCRONIZACIÓN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),

          // TARJETA DE GOOGLE SHEETS MEJORADA
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: colorTarjeta,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_done, color: Colors.green),
                ),
                title: Text(
                  'Google Sheets Conectado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorTexto,
                  ),
                ),
                subtitle: Text(
                  'Sincronización mediante Apps Script',
                  style: TextStyle(
                    color: esOscuro ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
