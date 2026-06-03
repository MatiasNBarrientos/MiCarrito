import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'APARIENCIA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey, width: 0.2),
            ),
            child: SwitchListTile(
              activeColor: const Color(0xFFD49EEB),
              title: const Text('Modo Oscuro'),
              subtitle: const Text('Forzar colores oscuros en la aplicación'),
              value: _modoOscuroActivado,
              onChanged: _cambiarTema,
              secondary: Icon(
                _modoOscuroActivado ? Icons.dark_mode : Icons.light_mode,
                color: _modoOscuroActivado
                    ? const Color(0xFFD49EEB)
                    : Colors.orange,
              ),
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            'DATOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey, width: 0.2),
            ),
            child: const ListTile(
              leading: Icon(Icons.cloud_done, color: Color(0xFFD49EEB)),
              title: Text('Google Sheets Conectado'),
              subtitle: Text('Sincronización mediante Apps Script'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
