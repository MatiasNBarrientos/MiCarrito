import 'package:flutter/material.dart';
import '/models/producto.dart';
import 'agregar_producto.dart';

class PantallaDetalleProducto extends StatefulWidget {
  final Producto producto;
  final Function(Producto) onEditar;
  final Function(String) onBorrar;

  const PantallaDetalleProducto({
    super.key,
    required this.producto,
    required this.onEditar,
    required this.onBorrar,
  });

  @override
  State<PantallaDetalleProducto> createState() =>
      _PantallaDetalleProductoState();
}

class _PantallaDetalleProductoState extends State<PantallaDetalleProducto> {
  late Producto _prod;

  @override
  void initState() {
    super.initState();
    _prod = widget.producto;
  }

  Future<void> _vincularCodigoBarras() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El escaneo esta temporalmente deshabilitado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _abrirFormularioEdicion() {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: esOscuro ? const Color(0xFF1A1A1A) : Colors.white,
      builder: (_) => AgregarProductoForm(
        productoAEditar: _prod,
        onGuardar: (productoEditado) {
          setState(() => _prod = productoEditado);
          widget.onEditar(productoEditado);
        },
      ),
    );
  }

  Color _obtenerColorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'lácteos':
        return Colors.blue.shade100;
      case 'almacén':
        return Colors.orange.shade100;
      case 'verdulería':
        return Colors.green.shade100;
      case 'carnicería':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  IconData _obtenerIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'lácteos':
        return Icons.water_drop;
      case 'almacén':
        return Icons.inventory_2;
      case 'verdulería':
        return Icons.eco;
      case 'carnicería':
        return Icons.set_meal;
      default:
        return Icons.shopping_bag;
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
    final colorSub = esOscuro ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: colorFondo,
      body: Stack(
        children: [
          // --- FONDO CON GRADIENTE (CABECERA) ---
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFD500F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // --- BARRA DE NAVEGACIÓN SUPERIOR (Transparente) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Detalles del Producto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      widget.onBorrar(_prod.id);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- CONTENEDOR PRINCIPAL BLANCO/OSCURO ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height:
                  MediaQuery.of(context).size.height -
                  200, // Ocupa el resto de la pantalla
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              decoration: BoxDecoration(
                color: colorFondo,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Título y Categoría
                    Text(
                      _prod.nombre,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colorTexto,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _prod.categoria.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD49EEB),
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Fila de Cantidad y Precio Unitario
                    Row(
                      children: [
                        Expanded(
                          child: _crearTarjetaInfo(
                            titulo: 'Cantidad',
                            valor: '${_prod.cantidad}',
                            icono: Icons.shopping_basket,
                            colorFondo: colorTarjeta,
                            colorTexto: colorTexto,
                            colorSub: colorSub,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _crearTarjetaInfo(
                            titulo: 'Precio Un.',
                            valor:
                                '\$${_prod.precioUnitario.toStringAsFixed(2)}',
                            icono: Icons.sell,
                            colorFondo: colorTarjeta,
                            colorTexto: colorTexto,
                            colorSub: colorSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Tarjeta Grande del Total Estimado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6A1B9A,
                            ).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TOTAL ESTIMADO',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '\$${_prod.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Tarjeta de Código de Barras
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorTarjeta,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD49EEB,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.qr_code,
                              color: Color(0xFFD49EEB),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Código de Barras',
                                  style: TextStyle(
                                    color: colorSub,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _prod.codigoBarras ?? 'No asignado',
                                  style: TextStyle(
                                    color: _prod.codigoBarras == null
                                        ? Colors.grey
                                        : colorTexto,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Color(0xFFD49EEB),
                              size: 30,
                            ),
                            onPressed: _vincularCodigoBarras,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Tarjeta de Estado (Comprado o No)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _prod.comprado
                            ? Colors.green.withValues(alpha: 0.1)
                            : colorTarjeta,
                        borderRadius: BorderRadius.circular(20),
                        border: _prod.comprado
                            ? Border.all(color: Colors.green.shade300, width: 2)
                            : Border.all(color: Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _prod.comprado
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: _prod.comprado ? Colors.green : colorSub,
                                size: 28,
                              ),
                              const SizedBox(width: 15),
                              Text(
                                _prod.comprado
                                    ? '¡Producto Comprado!'
                                    : 'Pendiente de compra',
                                style: TextStyle(
                                  color: _prod.comprado
                                      ? Colors.green.shade700
                                      : colorTexto,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Checkbox(
                            value: _prod.comprado,
                            activeColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onChanged: (val) {
                              setState(() => _prod.comprado = val ?? false);
                              widget.onEditar(_prod);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ), // Espacio para que no tape el botón flotante
                  ],
                ),
              ),
            ),
          ),

          // --- ÍCONO GIGANTE FLOTANTE DE LA CATEGORÍA ---
          Positioned(
            top: 140, // Justo entre el gradiente y el contenedor blanco
            left:
                MediaQuery.of(context).size.width / 2 - 50, // Centrado perfecto
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _obtenerColorCategoria(_prod.categoria),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorFondo,
                  width: 6,
                ), // Borde grueso para separar del fondo
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _obtenerIconoCategoria(_prod.categoria),
                size: 50,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),

      // --- BOTÓN FLOTANTE PARA EDITAR ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD49EEB),
        elevation: 6,
        onPressed: _abrirFormularioEdicion,
        child: const Icon(Icons.edit, size: 28, color: Colors.white),
      ),
    );
  }

  // --- WIDGET REUTILIZABLE PARA TARJETITAS PEQUEÑAS ---
  Widget _crearTarjetaInfo({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color colorFondo,
    required Color colorTexto,
    required Color colorSub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 16, color: colorSub),
              const SizedBox(width: 8),
              Text(titulo, style: TextStyle(color: colorSub, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: TextStyle(
              color: colorTexto,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
