import 'package:flutter/material.dart';
import '/models/producto.dart';
import '../services/sheets_service.dart';
import 'detalle_producto.dart';
import 'modal_presets.dart';
import 'agregar_producto.dart';
import 'pantalla_escaneo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaListaCompras extends StatefulWidget {
  final Function(Function())? onRegistrarFab;
  const PantallaListaCompras({super.key, this.onRegistrarFab});

  @override
  State<PantallaListaCompras> createState() => _PantallaListaComprasState();
}

class _PantallaListaComprasState extends State<PantallaListaCompras> {
  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    // Ahora el botón "+" central usa nuestro formulario avanzado
    widget.onRegistrarFab?.call(() => _abrirFormulario(context));
    _cargarDatos();
  }

 Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final productos = await SheetsService.obtenerProductos();

    // Calculamos el total de los productos que acabamos de descargar
    double totalCalculado = productos.fold(
      0,
      (suma, item) => suma + (item.precioUnitario * item.cantidad),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('total_carrito_abierto', totalCalculado);

    setState(() {
      _productos = productos;
      _cargando = false;
    });
  }

  double get _totalEstimado {
    return _productos.fold(
      0,
      (suma, item) => suma + (item.precioUnitario * item.cantidad),
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

  // =======================================================
  // MAGIA: USAMOS EL FORMULARIO AVANZADO
  // =======================================================
  void _abrirFormulario(BuildContext context, {String? codigoEscaneado}) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: esOscuro ? const Color(0xFF1A1A1A) : Colors.white,
      builder: (_) => AgregarProductoForm(
        codigoBarrasPrellenado:
            codigoEscaneado, // Pasa el código si escaneaste antes
        onGuardar: (nuevoProducto) async {
          setState(() => _cargando = true);
          await SheetsService.enviarAccion(nuevoProducto, 'ADD');
          await _cargarDatos();
        },
      ),
    );
  }

  // =======================================================
  // MENÚ DE LAS 3 RALLITAS (HERRAMIENTAS)
  // =======================================================
  void _mostrarModalHerramientas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctxModal) => Padding(
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
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              ),
              title: const Text(
                'Escanear Código',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Agregar un producto con la cámara'),
              onTap: () async {
                Navigator.pop(ctxModal); // Cierra el menucito de abajo

                // Abre el escáner
                final codigo = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaEscaneo(),
                  ),
                );

                // Si encontró un código, abre el formulario y se lo pega automático
                if (codigo != null && context.mounted) {
                  _abrirFormulario(context, codigoEscaneado: codigo);
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.star, color: Colors.orange)),
              title: const Text('Productos Frecuentes', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Elegir desde tus presets'),
              onTap: () { 
                Navigator.pop(ctxModal); // Cierra el menucito de las 3 rallitas
                
                // Abre nuestra nueva pantalla de Presets
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => ModalPresets(
                    onAgregar: (productoDesdePreset) async {
                      // Cuando toques un preset, se ejecuta esto:
                      setState(() => _cargando = true);
                      await SheetsService.enviarAccion(productoDesdePreset, 'ADD');
                      await _cargarDatos(); 
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('¡${productoDesdePreset.nombre} agregado!'), backgroundColor: Colors.green),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final colorFondoPrincipal = esOscuro
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);
    final colorTarjetasGrosas = esOscuro
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFF8A2BE2),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFFD500F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. ACHICAR EL RELLENO (PADDING) VERTICAL
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, 
                  vertical: 0.0, // <-- Bajalo de 10.0 a 4.0 (o a 0.0)
                ),
                child: Row(
                  children: [
                    // 2. ACHICAR EL BOTÓN DE LAS 3 RALLITAS
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 26), // <-- Bajalo de 32 a 26
                      onPressed: () => _mostrarModalHerramientas(context),
                    ),
                    const SizedBox(width: 10),
                    // 3. ACHICAR EL ÍCONO DEL CARRITO
                    const Icon(Icons.shopping_cart, color: Colors.white, size: 22), // <-- Bajalo de 28 a 22
                    const SizedBox(width: 10),
                    // 4. ACHICAR EL TEXTO DEL TÍTULO
                    const Text('MiCarrito', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), // <-- Bajalo de 24 a 20
                  ],
                ),
              ),
              const SizedBox(height: 0), // <-- Bajá este espacio de 10 a 5
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorFondoPrincipal,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB388FF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Producto',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Cant.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _cargando
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6A1B9A),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _productos.length,
                                itemBuilder: (context, index) =>
                                    _construirTarjetaProducto(
                                      context,
                                      _productos[index],
                                    ),
                              ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 50,
                          top: 10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: colorTarjetasGrosas,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                                const Text(
                                  'TOTAL ESTIMADO:',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${_totalEstimado.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFFD49EEB),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A1B9A),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'CERRAR CARRITO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                onPressed: _productos.isEmpty
                                    ? null
                                    : () async {
                                        setState(() => _cargando = true);
                                        final productoFalso = Producto(
                                          nombre: 'compra',
                                          categoria: 'Otros',
                                        );
                                        await SheetsService.enviarAccion(
                                          productoFalso,
                                          'COMPRAR',
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '¡Compra archivada en el Historial!',
                                              ),
                                              backgroundColor: Color.fromARGB(255, 47, 255, 0),
                                            ),
                                          );
                                        }
                                        await _cargarDatos();
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _construirTarjetaProducto(BuildContext context, Producto producto) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    // --- COLORES NORMALES ---
    final colorTarjetaNormal = esOscuro
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final colorTextoNormal = esOscuro ? Colors.white : Colors.black87;
    final colorTextoSecundario = esOscuro ? Colors.white70 : Colors.black54;

    // --- COLORES MODO "TACHADO/ROJO" ---
    final colorTarjetaComprado = esOscuro
        ? const Color.fromARGB(255, 82, 255, 108).withOpacity(0.15)
        : Colors.red.shade50;
    final colorTextoComprado = esOscuro
        ? Colors.white54
        : const Color.fromARGB(255, 28, 183, 33).withOpacity(0.6);

    // --- ELECCIÓN DINÁMICA ---
    final bgTarjeta = producto.comprado
        ? colorTarjetaComprado
        : colorTarjetaNormal;
    final colorTexto = producto.comprado
        ? colorTextoComprado
        : colorTextoNormal;
    final colorSub = producto.comprado
        ? colorTextoComprado
        : colorTextoSecundario;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaDetalleProducto(
              producto: producto,
              onEditar: (productoEditado) async {
                setState(() => _cargando = true);
                await SheetsService.enviarAccion(productoEditado, 'UPDATE');
                await _cargarDatos();
              },
              onBorrar: (idABorrar) async {
                setState(() => _cargando = true);
                final productoFalso = Producto(
                  id: idABorrar,
                  nombre: '',
                  categoria: 'Otros',
                );
                await SheetsService.enviarAccion(productoFalso, 'DELETE');
                await _cargarDatos();
              },
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgTarjeta, // <-- FONDO QUE SE TIÑE
          borderRadius: BorderRadius.circular(15),
          border: producto.comprado
              ? Border.all(color: const Color.fromARGB(255, 88, 255, 82).withOpacity(0.3), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
          boxShadow: [
            if (!producto
                .comprado) // Apagamos la sombra al tachar para dar efecto "hundido"
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // ==========================================
            // 1. EL CONTENIDO DE LA TARJETA
            // ==========================================
            Row(
              children: [
                Checkbox(
                  value: producto.comprado,
                  activeColor: const Color.fromARGB(255, 82, 255, 108), // <-- El check ahora es rojo
                  side: BorderSide(color: colorSub, width: 1.5),
                  onChanged: (bool? valor) async {
                    setState(() => producto.comprado = valor ?? false);
                    await SheetsService.enviarAccion(producto, 'UPDATE');
                  },
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    // Para que el ícono quede grisáceo si está comprado
                    color: producto.comprado
                        ? Colors.grey.withOpacity(0.1)
                        : _obtenerColorCategoria(producto.categoria),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _obtenerIconoCategoria(producto.categoria),
                    color: producto.comprado ? Colors.grey : Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: TextStyle(
                          color: colorTexto,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        producto.categoria,
                        style: TextStyle(
                          color: colorSub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: esOscuro
                        ? const Color(0xFF2C2C2C)
                        : (producto.comprado
                              ? const Color.fromARGB(255, 95, 244, 54).withOpacity(0.1)
                              : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          if (producto.cantidad > 1) {
                            setState(() => producto.cantidad--);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setDouble(
                              'total_carrito_abierto',
                              _totalEstimado,
                            );
                            await SheetsService.enviarAccion(
                              producto,
                              'UPDATE',
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorSub,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${producto.cantidad}',
                        style: TextStyle(
                          color: colorTexto,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          setState(() => producto.cantidad++);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setDouble(
                            'total_carrito_abierto',
                            _totalEstimado,
                          );
                          await SheetsService.enviarAccion(producto, 'UPDATE');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            '+',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorSub,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${producto.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colorTexto,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          Positioned.fill(
              child: Align(
                alignment: Alignment
                    .centerLeft, // <-- CAMBIAMOS EL 'Center' POR 'Align'
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: producto.comprado ? 1.0 : 0.0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      alignment: Alignment
                          .centerLeft, // <-- Ancla la animación a la izquierda
                      widthFactor: value, // 0.0 a 1.0 (0 a 100%)
                      child: Container(
                        height: 4.0, // Grosor del tachado
                        color: const Color.fromARGB(255, 82, 255, 122),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
