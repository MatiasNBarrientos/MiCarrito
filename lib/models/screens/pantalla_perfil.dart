import 'package:flutter/material.dart';
import 'configuracion.dart'; // Asegurate de tener configuracion.dart en la misma carpeta
import 'historial_meses.dart';
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final colorFondo = esOscuro
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- CABECERA DEL PERFIL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF6A1B9A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Mi Cuenta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Resistencia, Chaco',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- OPCIONES DEL PERFIL VINCULADAS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _crearBotonOpcion(
                    context,
                    Icons.history,
                    Colors.blue,
                    'Historial Mensual',
                    'Revisá tus meses archivados',
                    () {
                      // Mensaje temporal hasta que armemos la pantalla de Historial
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaHistorialMeses(),
                        ),
                      );
                    },
                  ),
                  _crearBotonOpcion(
                    context,
                    Icons.settings,
                    Colors.grey,
                    'Configuración',
                    'Modo oscuro y preferencias',
                    () {
                      // NAVEGA A LA CONFIGURACIÓN
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaConfiguracion(),
                        ),
                      );
                    },
                  ),
                  _crearBotonOpcion(
                    context,
                    Icons.info_outline,
                    const Color(0xFF6A1B9A),
                    'Información de la App',
                    'Versión 1.0.0',
                    () => _mostrarDialogoInfo(context), // ABRE EL MODAL
                  ),
                  _crearBotonOpcion(
                    context,
                    Icons.description,
                    Colors.orange,
                    'Términos y Condiciones',
                    'Legales y privacidad',
                    () => _mostrarDialogoTerminos(context), // ABRE EL MODAL
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- BOTÓN CERRAR SESIÓN ---
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesión cerrada localmente'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _crearBotonOpcion(
    BuildContext context,
    IconData icono,
    Color colorIcono,
    String titulo,
    String subtitulo,
    VoidCallback alPresionar,
  ) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final colorTarjeta = esOscuro ? const Color(0xFF1E1E1E) : Colors.white;
    final colorTitulo = esOscuro ? Colors.white : Colors.black87;
    final colorSub = esOscuro ? Colors.white54 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorTarjeta,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorIcono.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: colorIcono),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorTitulo,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(color: colorSub, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: alPresionar,
      ),
    );
  }

  // --- MODAL INFO ---
  void _mostrarDialogoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shopping_cart, color: Color(0xFF6A1B9A)),
            SizedBox(width: 10),
            Text('MiCarrito'),
          ],
        ),
        content: const Text(
          'Desarrollado para organizar compras y gastos de manera inteligente mediante Google Sheets.\n\nVersión actual: 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFF6A1B9A)),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL TÉRMINOS ---
  void _mostrarDialogoTerminos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Términos y Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Uso de Datos: Esta aplicación utiliza tu propia cuenta de Google Sheets como base de datos. Nadie más tiene acceso a tus compras.\n\n'
            '2. Privacidad: La app no recopila información personal en servidores externos.\n\n'
            '3. Uso sin conexión: Requiere conexión a internet para sincronizarse en tiempo real con Excel.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Aceptar',
              style: TextStyle(color: Color(0xFF6A1B9A)),
            ),
          ),
        ],
      ),
    );
  }
}
