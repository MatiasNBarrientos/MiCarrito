import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaHistorialMeses extends StatefulWidget {
  const PantallaHistorialMeses({super.key});

  @override
  State<PantallaHistorialMeses> createState() => _PantallaHistorialMesesState();
}

class _PantallaHistorialMesesState extends State<PantallaHistorialMeses> {
  List<Map<String, dynamic>> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datosGuardados = prefs.getString('historial_mensual');

    if (datosGuardados != null) {
      final List<dynamic> decodificado = jsonDecode(datosGuardados);
      setState(() {
        // Lo damos vuelta para que el mes más reciente aparezca arriba
        _historial = decodificado
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
            .reversed
            .toList();
      });
    }
  }

  Future<void> _borrarHistorialCompleto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historial_mensual');
    setState(() => _historial = []);
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
          'Historial Mensual',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_historial.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              onPressed: () => _borrarHistorialCompleto(),
            ),
        ],
      ),
      body: _historial.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Todavía no archivaste ningún mes',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historial.length,
              itemBuilder: (context, index) {
                final mes = _historial[index];
                final double saldo = mes['saldo'] ?? 0.0;
                final bool saldoPositivo = saldo >= 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorTarjeta,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mes['mes_texto'] ?? 'Mes Desconocido',
                            style: TextStyle(
                              color: colorTexto,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: saldoPositivo
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              saldoPositivo ? 'Sobrante' : 'Déficit',
                              style: TextStyle(
                                color: saldoPositivo
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _filaDato(
                        'Ingresos:',
                        mes['ingresos'] ?? 0.0,
                        Colors.green,
                      ),
                      _filaDato(
                        'Gastos Super:',
                        mes['gastosSuper'] ?? 0.0,
                        const Color(0xFF6A1B9A),
                      ),
                      _filaDato(
                        'Otros Gastos:',
                        mes['gastosExternos'] ?? 0.0,
                        Colors.orange,
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SALDO FINAL:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '\$${saldo.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: saldoPositivo
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _filaDato(String etiqueta, double monto, Color colorMonto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            '\$${monto.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorMonto,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
