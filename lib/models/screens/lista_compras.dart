import 'package:flutter/material.dart';
import '/models/producto.dart';
import '../services/sheets_service.dart';

class PantallaListaCompras extends StatefulWidget {
  const PantallaListaCompras({super.key});

  @override
  State<PantallaListaCompras> createState() => _PantallaListaComprasState();
}

class _PantallaListaComprasState extends State<PantallaListaCompras> {
  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final productos = await SheetsService.obtenerProductos();
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

  // Colores dinámicos para los íconos según categoría
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
    return Scaffold(
      // Evitamos el fondo por defecto para usar nuestro gradiente
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
          bottom: false, // Para que el blanco llegue hasta el fondo
          child: Column(
            children: [
              // --- APP BAR CUSTOM ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        // Acá podés abrir un Drawer o ir a Configuración
                      },
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'MiCarrito',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // --- CONTENEDOR BLANCO PRINCIPAL ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA), // Un gris/blanco muy suavecito
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // --- CABECERA DE LA LISTA ---
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB388FF), // Violeta clarito
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

                      // --- LISTA DE PRODUCTOS ---
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
                                itemBuilder: (context, index) {
                                  final producto = _productos[index];
                                  return _construirTarjetaProducto(producto);
                                },
                              ),
                      ),

                      // --- BARRA DE TOTAL ESTIMADO ---
                      Container(
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 80,
                          top: 10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
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
                                color: Color(0xFF6A1B9A),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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

      // --- BOTÓN FLOTANTE CENTRAL (+) ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarModalOpciones(context);
        },
        backgroundColor: const Color(0xFF6A1B9A),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      // --- BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Lado Izquierdo
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  // Ya estamos en el carrito
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, color: Color(0xFF6A1B9A)),
                    Text(
                      'Carrito',
                      style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 10),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  // Navegar al Comparador
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.balance, color: Colors.grey),
                    Text(
                      'Comparar',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 40,
              ), // Espacio para el botón flotante central
              // Lado Derecho
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  // Navegar a Análisis/Historial
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics, color: Colors.grey),
                    Text(
                      'Gastos',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  // Navegar al Perfil
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: Colors.grey),
                    Text(
                      'Perfil',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODAL DEL BOTÓN + ---
  void _mostrarModalOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
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
                    color: const Color(0xFF6A1B9A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                title: const Text(
                  'Agregar al Carrito',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Sumar un producto nuevo a la lista'),
                onTap: () {
                  Navigator.pop(context);
                  // Acá llamamos al modal viejo de crear producto
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.balance, color: Colors.orange),
                ),
                title: const Text(
                  'Comparar Precios',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Ver qué producto rinde más'),
                onTap: () {
                  Navigator.pop(context);
                  // Acá abrimos la herramienta del comparador
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET DE LA TARJETA DE PRODUCTO ---
  Widget _construirTarjetaProducto(Producto producto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: producto.comprado,
            activeColor: const Color(0xFF6A1B9A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? valor) async {
              setState(() => producto.comprado = valor ?? false);
              await SheetsService.enviarAccion(producto, 'UPDATE');
            },
          ),

          // Ícono circular
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _obtenerColorCategoria(producto.categoria),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _obtenerIconoCategoria(producto.categoria),
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 12),

          // Nombre y categoría
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  producto.categoria,
                  style: TextStyle(
                    color: _obtenerColorCategoria(
                      producto.categoria,
                    ).withOpacity(1.0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Selector de cantidad
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    if (producto.cantidad > 1) {
                      setState(() => producto.cantidad--);
                      await SheetsService.enviarAccion(producto, 'UPDATE');
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${producto.cantidad}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () async {
                    setState(() => producto.cantidad++);
                    await SheetsService.enviarAccion(producto, 'UPDATE');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Precio y flecha
          Text(
            '\$${producto.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
