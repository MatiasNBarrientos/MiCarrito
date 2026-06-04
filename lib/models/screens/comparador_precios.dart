import 'package:flutter/material.dart';

class PantallaComparador extends StatefulWidget {
  final Function(Function())? onRegistrarFab;
  const PantallaComparador({super.key, this.onRegistrarFab});

  @override
  State<PantallaComparador> createState() => _PantallaComparadorState();
}

class OpcionComparacion {
  final TextEditingController precioCtrl = TextEditingController();
  final TextEditingController cantidadCtrl = TextEditingController();
  String unidad = 'g / ml';
  double precioPorUnidad = -1;
}

class _PantallaComparadorState extends State<PantallaComparador> {
  // Arrancamos por defecto con dos opciones para comparar
  final List<OpcionComparacion> _opciones = [
    OpcionComparacion(),
    OpcionComparacion(),
  ];
  final List<String> _unidades = ['g / ml', 'Kg / L', 'Unidades'];

  String _mensajeResultado = 'Ingresá datos para comparar';
  Color _colorResultado = Colors.grey;
  String _detalleResultado = '';

  @override
  void initState() {
    super.initState();
    // Le avisamos al jefe (PantallaPrincipal) que si tocan el +, ejecute esta función:
    widget.onRegistrarFab?.call(agregarOpcionNueva);
  }

  void agregarOpcionNueva() {
    setState(() {
      _opciones.add(OpcionComparacion());
      _calcularMejorOpcion();
    });
  }

  void _eliminarOpcion(int index) {
    if (_opciones.length > 2) {
      setState(() {
        _opciones.removeAt(index);
        _calcularMejorOpcion();
      });
    }
  }

  void _calcularMejorOpcion() {
    bool faltaData = false;
    double mejorPrecio = double.infinity;
    int indiceGanador = -1;

    for (int i = 0; i < _opciones.length; i++) {
      final op = _opciones[i];
      double precio = double.tryParse(op.precioCtrl.text) ?? 0;
      double cant = double.tryParse(op.cantidadCtrl.text) ?? 0;

      if (precio <= 0 || cant <= 0) {
        faltaData = true;
        op.precioPorUnidad = -1;
        continue;
      }

      // Normalizamos: Si dice Kilos/Litros, lo multiplicamos por 1000
      double cantNorm = op.unidad == 'Kg / L' ? cant * 1000 : cant;
      op.precioPorUnidad = precio / cantNorm;

      if (op.precioPorUnidad < mejorPrecio) {
        mejorPrecio = op.precioPorUnidad;
        indiceGanador = i;
      }
    }

    setState(() {
      if (faltaData) {
        _mensajeResultado = 'Faltan datos válidos';
        _detalleResultado = 'Asegurate de completar precio y cantidad.';
        _colorResultado = Colors.orange;
        return;
      }

      int empates = _opciones
          .where((o) => o.precioPorUnidad == mejorPrecio)
          .length;
      if (empates > 1) {
        _mensajeResultado = '¡Hay un empate!';
        _detalleResultado = 'Varias opciones tienen el mismo costo por unidad.';
        _colorResultado = Colors.blue;
      } else {
        String letraGanador = String.fromCharCode(
          65 + indiceGanador,
        ); // 0=A, 1=B, etc.
        _mensajeResultado = '¡La Opción $letraGanador es mejor!';
        _detalleResultado = 'Es la más barata en proporción.';
        _colorResultado = Colors.green;
      }
    });
  }

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
        title: const Text(
          'Comparador Múltiple',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // PANEL DE RESULTADO ARRIBA
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _colorResultado.withValues(alpha: esOscuro ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _colorResultado, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.balance, size: 40, color: _colorResultado),
                const SizedBox(height: 10),
                Text(
                  _mensajeResultado,
                  style: TextStyle(
                    color: _colorResultado,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_detalleResultado.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    _detalleResultado,
                    style: TextStyle(
                      color: esOscuro ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          // LISTA DE OPCIONES DINÁMICA
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(bottom: 100),
              itemCount: _opciones.length,
              itemBuilder: (context, index) {
                final op = _opciones[index];
                final letra = String.fromCharCode(65 + index);
                final esGanador = _mensajeResultado.contains('Opción $letra');
                final colorBorde = esGanador
                    ? Colors.green
                    : const Color(0xFFD49EEB);

                return _construirTarjetaOpcion(letra, op, colorBorde, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaOpcion(
    String letra,
    OpcionComparacion op,
    Color colorBorde,
    int index,
  ) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final colorTarjeta = esOscuro ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorTarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorBorde,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Opción $letra',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_opciones.length > 2)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => _eliminarOpcion(index),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: op.precioCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Precio \$',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: colorBorde,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) => _calcularMejorOpcion(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: op.cantidadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    prefixIcon: Icon(Icons.scale, color: colorBorde, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) => _calcularMejorOpcion(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: op.unidad,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            items: _unidades
                .map(
                  (u) => DropdownMenuItem(
                    value: u,
                    child: Text(u, style: const TextStyle(fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => op.unidad = val!);
              _calcularMejorOpcion();
            },
          ),
        ],
      ),
    );
  }
}
