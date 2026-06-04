import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sheets_service.dart';

class PantallaAnalisisGastos extends StatefulWidget {
  final Function(Function())? onRegistrarFab;
  const PantallaAnalisisGastos({super.key, this.onRegistrarFab});

  @override
  State<PantallaAnalisisGastos> createState() => _PantallaAnalisisGastosState();
}

class _PantallaAnalisisGastosState extends State<PantallaAnalisisGastos> {
  double _ingresoTotal = 0.0;
  double _gastosSupermercado = 0.0;
  List<Map<String, dynamic>> _gastosExternos = [];

  double get _totalGastosExternos =>
      _gastosExternos.fold(0, (suma, item) => suma + item['monto']);
  double get _gastosTotales => _gastosSupermercado + _totalGastosExternos;
  double get _saldoRestante => _ingresoTotal - _gastosTotales;
  double get _porcentajeGastado => _ingresoTotal > 0
      ? (_gastosTotales / _ingresoTotal).clamp(0.0, 1.0)
      : 0.0;

  @override
  void initState() {
    super.initState();
    widget.onRegistrarFab?.call(_mostrarMenuAgregar);
    _cargarDatosLocales();
  }

  Future<void> _cargarDatosLocales() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ingresoTotal = prefs.getDouble('ingreso_total') ?? 0.0;
      final String? gastosString = prefs.getString('gastos_externos');
      if (gastosString != null) {
        final List<dynamic> decodificado = jsonDecode(gastosString);
        _gastosExternos = decodificado
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    });

    final totalSuper = await SheetsService.obtenerTotalHistorial();
    if (mounted) {
      setState(() => _gastosSupermercado = totalSuper);
    }
  }

  Future<void> _guardarIngreso() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ingreso_total', _ingresoTotal);
  }

  Future<void> _guardarGastosExternos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gastos_externos', jsonEncode(_gastosExternos));
  }

  // --- FUNCIÓN MANUAL PARA CERRAR EL MES (Por si no querés esperar al cierre automático) ---
  Future<void> _archivarMesActual() async {
    final prefs = await SharedPreferences.getInstance();
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
    final fecha = DateTime.now();
    final nombreMes = '${meses[fecha.month - 1]} ${fecha.year}';

    final Map<String, dynamic> snapshotMes = {
      'mes_texto': nombreMes,
      'ingresos': _ingresoTotal,
      'gastosSuper': _gastosSupermercado,
      'gastosExternos': _totalGastosExternos,
      'saldo': _saldoRestante,
      'timestamp': fecha.millisecondsSinceEpoch,
    };

    final String? datosGuardados = prefs.getString('historial_mensual');
    List<dynamic> historial = datosGuardados != null
        ? jsonDecode(datosGuardados)
        : [];
    historial.add(snapshotMes);

    // 1. Guardamos el historial en formato texto (String)
    final historialString = jsonEncode(historial);

    // 2. Lo guardamos en la memoria local del celular
    await prefs.setString('historial_mensual', historialString);

    // 3. ¡LA MAGIA! Lo mandamos a nuestro Google Apps Script para que cree el archivo en Drive
    await SheetsService.hacerBackupEnDrive(historialString);

    setState(() {
      _gastosExternos.clear();
      _gastosSupermercado = 0.0;
    });
    await _guardarGastosExternos();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Mes de $nombreMes archivado!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _mostrarMenuAgregar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¿Qué querés registrar?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                ),
              ),
              title: const Text(
                'Fijar Ingreso / Sueldo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoIngreso();
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.money_off, color: Colors.redAccent),
              ),
              title: const Text(
                'Agregar Gasto Externo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoGastoExterno();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoIngreso() {
    final ingresoCtrl = TextEditingController(
      text: _ingresoTotal > 0 ? _ingresoTotal.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Definir Ingresos',
          style: TextStyle(
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: ingresoCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Sueldo (\$)',
            prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.green),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
            ),
            onPressed: () {
              setState(
                () => _ingresoTotal = double.tryParse(ingresoCtrl.text) ?? 0.0,
              );
              _guardarIngreso();
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoGastoExterno() {
    final nombreCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agregar Gasto Externo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.receipt_long),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto (\$)',
                prefixIcon: Icon(Icons.attach_money, color: Colors.red),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  if (nombreCtrl.text.isNotEmpty && montoCtrl.text.isNotEmpty) {
                    setState(
                      () => _gastosExternos.add({
                        'nombre': nombreCtrl.text,
                        'monto': double.tryParse(montoCtrl.text) ?? 0.0,
                      }),
                    );
                    _guardarGastosExternos();
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Agregar Gasto',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _mostrarGraficoPastel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final esOscuro = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Distribución de tu Dinero',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: PastelPainter(
                    _ingresoTotal,
                    _gastosSupermercado,
                    _totalGastosExternos,
                    esOscuro,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _crearLeyendaGrafico(
                color: const Color(0xFF6A1B9A),
                titulo: 'Supermercado',
                monto: _gastosSupermercado,
              ),
              _crearLeyendaGrafico(
                color: Colors.orange,
                titulo: 'Gastos Externos',
                monto: _totalGastosExternos,
              ),
              _crearLeyendaGrafico(
                color: esOscuro ? Colors.grey.shade800 : Colors.grey.shade300,
                titulo: 'Dinero Restante',
                monto: _saldoRestante > 0 ? _saldoRestante : 0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _crearLeyendaGrafico({
    required Color color,
    required String titulo,
    required double monto,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '\$${monto.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text(
          'Análisis Financiero',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFFD500F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'SALDO DISPONIBLE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${_saldoRestante.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _saldoRestante < 0
                          ? Colors.redAccent.shade100
                          : Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _porcentajeGastado,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _porcentajeGastado > 0.9
                            ? Colors.redAccent
                            : Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- BOTÓN RESTAURADO DEL ANÁLISIS AVANZADO ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorTarjeta,
                  foregroundColor: const Color(0xFF6A1B9A),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.pie_chart),
                label: const Text(
                  'Ver Análisis Avanzado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: _mostrarGraficoPastel,
              ),
            ),
            const SizedBox(height: 30),

            // --- DESGLOSE DE GASTOS RESTAURADO ---
            Text(
              'DESGLOSE DE GASTOS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            _crearTarjetaGasto(
              context,
              'Supermercado (Carrito)',
              _gastosSupermercado,
              Icons.shopping_cart,
              const Color(0xFF6A1B9A),
              colorTarjeta,
              colorTexto,
            ),
            ..._gastosExternos.asMap().entries.map((entry) {
              return _crearTarjetaGasto(
                context,
                entry.value['nombre'],
                entry.value['monto'],
                Icons.receipt_long,
                Colors.orange,
                colorTarjeta,
                colorTexto,
                onBorrar: () {
                  setState(() => _gastosExternos.removeAt(entry.key));
                  _guardarGastosExternos();
                },
              );
            }),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
                icon: const Icon(Icons.archive),
                label: const Text(
                  'CERRAR Y ARCHIVAR MES',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('¿Cerrar el mes?'),
                      content: const Text(
                        'Se guardará un resumen en tu historial y se limpiarán los gastos externos.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _archivarMesActual();
                          },
                          child: const Text(
                            'Archivar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _crearTarjetaGasto(
    BuildContext context,
    String titulo,
    double monto,
    IconData icono,
    Color colorIcono,
    Color bgTarjeta,
    Color colorTexto, {
    VoidCallback? onBorrar,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgTarjeta,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorIcono.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: colorIcono),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorTexto,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${monto.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
            if (onBorrar != null) ...[
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: onBorrar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PastelPainter extends CustomPainter {
  final double totalIngresos;
  final double superM;
  final double externos;
  final bool esOscuro;

  PastelPainter(this.totalIngresos, this.superM, this.externos, this.esOscuro);

  @override
  void paint(Canvas canvas, Size size) {
    double totalAGraficar = totalIngresos > 0
        ? totalIngresos
        : (superM + externos);
    if (totalAGraficar <= 0) return;
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    double superAngle = (superM / totalAGraficar) * 2 * pi;
    double extAngle = (externos / totalAGraficar) * 2 * pi;
    double gastosSumados = superM + externos;
    double restanteAngle = totalIngresos > gastosSumados
        ? ((totalIngresos - gastosSumados) / totalAGraficar) * 2 * pi
        : 0.0;

    paint.color = const Color(0xFF6A1B9A);
    canvas.drawArc(rect, -pi / 2, superAngle, true, paint);
    paint.color = Colors.orange;
    canvas.drawArc(rect, -pi / 2 + superAngle, extAngle, true, paint);
    if (restanteAngle > 0) {
      paint.color = esOscuro ? Colors.grey.shade800 : Colors.grey.shade300;
      canvas.drawArc(
        rect,
        -pi / 2 + superAngle + extAngle,
        restanteAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
