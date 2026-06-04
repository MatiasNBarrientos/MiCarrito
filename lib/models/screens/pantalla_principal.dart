import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sheets_service.dart';
import 'lista_compras.dart';
import 'comparador_precios.dart';
import 'analisis_gastos.dart';
import 'pantalla_perfil.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;

  VoidCallback? _accionFabCarrito;
  VoidCallback? _accionFabComparador;
  VoidCallback? _accionFabGastos;

  late List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pantallas = [
      PantallaListaCompras(
        onRegistrarFab: (accion) => _accionFabCarrito = accion,
      ),
      PantallaComparador(
        onRegistrarFab: (accion) => _accionFabComparador = accion,
      ),
      PantallaAnalisisGastos(
        onRegistrarFab: (accion) => _accionFabGastos = accion,
      ),
      const PantallaPerfil(),
    ];

    // --- EL BOT INVISIBLE QUE REVISA LA FECHA AL ABRIR LA APP ---
    _verificarCierreAutomatico();
  }

  // ========================================================
  // BOT AUTOMÁTICO DE CIERRE MENSUAL
  // ========================================================
  Future<void> _verificarCierreAutomatico() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = DateTime.now();

    // Leemos qué mes fue la última vez que abriste la app (Por defecto, hoy)
    final mesGuardado = prefs.getInt('mes_actual_tracker') ?? hoy.month;

    // Si el mes de hoy no es igual al que teníamos guardado, ¡cambiamos de mes!
    if (hoy.month != mesGuardado) {
      // 1. Recopilar la información del mes que terminó desde la memoria
      final ingreso = prefs.getDouble('ingreso_total') ?? 0.0;

      final gastosString = prefs.getString('gastos_externos');
      double totalExternos = 0.0;
      if (gastosString != null) {
        final List<dynamic> decodificado = jsonDecode(gastosString);
        for (var g in decodificado) {
          totalExternos += (g['monto'] ?? 0.0);
        }
      }

      // Leemos el total del Excel
      final totalSuper = await SheetsService.obtenerTotalHistorial();
      final saldo = ingreso - (totalSuper + totalExternos);

      // 2. Determinar el nombre del mes pasado (Ej: Si es Febrero, cerramos Enero)
      final meses = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      int mesAnteriorIdx = hoy.month - 2;
      int anioAnterior = hoy.year;

      // Si estamos en Enero (mes 1), el mes pasado es Diciembre (índice 11) del año anterior
      if (mesAnteriorIdx < 0) {
        mesAnteriorIdx = 11;
        anioAnterior--;
      }
      final nombreMesPasado = '${meses[mesAnteriorIdx]} $anioAnterior';

      // 3. Crear la "foto" financiera del mes
      final Map<String, dynamic> snapshotMes = {
        'mes_texto': nombreMesPasado,
        'ingresos': ingreso,
        'gastosSuper': totalSuper,
        'gastosExternos': totalExternos,
        'saldo': saldo,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // 4. Guardar en el historial de la pantalla de Perfil
      final String? datosGuardados = prefs.getString('historial_mensual');
      List<dynamic> historial = [];
      if (datosGuardados != null) {
        historial = jsonDecode(datosGuardados);
      }
      historial.add(snapshotMes);
      await prefs.setString('historial_mensual', jsonEncode(historial));

      // 5. Limpiar los gastos externos para el nuevo mes (El sueldo lo dejamos igual)
      await prefs.remove('gastos_externos');

      // 6. Actualizamos el tracker para que no vuelva a cerrar hasta el próximo mes
      await prefs.setInt('mes_actual_tracker', hoy.month);

      // 7. Avisarte con un cartelito verde al abrir la app
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Mes de $nombreMesPasado archivado automáticamente!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } else {
      // Si es la primera vez que abrís la app en tu vida, guardamos el mes actual para empezar a trackear
      if (!prefs.containsKey('mes_actual_tracker')) {
        await prefs.setInt('mes_actual_tracker', hoy.month);
      }
    }
  }

  // ========================================================
  // NAVEGACIÓN Y DISEÑO
  // ========================================================
  void _alTocarBotonMas() {
    if (_indiceActual == 0 && _accionFabCarrito != null) {
      _accionFabCarrito!();
    } else if (_indiceActual == 1 && _accionFabComparador != null) {
      _accionFabComparador!();
    } else if (_indiceActual == 2 && _accionFabGastos != null) {
      _accionFabGastos!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final colorBarra = esOscuro ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      body: IndexedStack(index: _indiceActual, children: _pantallas),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _indiceActual < 3
          ? FloatingActionButton(
              onPressed: _alTocarBotonMas,
              backgroundColor: const Color(0xFF6A1B9A),
              shape: const CircleBorder(),
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,

bottomNavigationBar: BottomAppBar(
        padding:
            EdgeInsets.only(top: 18), // <-- ESTO QUITA EL RELLENO GIGANTE POR DEFECTO
        height:50, // <-- ALTURA FIJA (Podés bajarlo a 55 si la querés aún más fina)
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: colorBarra,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _crearBotonNavegacion(0, Icons.shopping_cart, 'Carrito'),
            _crearBotonNavegacion(1, Icons.balance, 'Comparar'),
            const SizedBox(width: 40), // El hueco para el botón +
            _crearBotonNavegacion(2, Icons.analytics, 'Gastos'),
            _crearBotonNavegacion(3, Icons.person, 'Perfil'),
          ],
        ),
      ),
    );
  }

  // --- BOTONES MÁS COMPACTOS ---
  Widget _crearBotonNavegacion(int indice, IconData icono, String texto) {
    final estaSeleccionado = _indiceActual == indice;
    final color = estaSeleccionado ? const Color(0xFF6A1B9A) : Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _indiceActual = indice),
      behavior:
          HitTestBehavior.opaque, // Para que el botón detecte el toque fácil
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(
              height: 2,
            ), // Apenas un respiro entre el ícono y el texto
            Text(
              texto,
              style: TextStyle(color: color, fontSize: 10, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}
