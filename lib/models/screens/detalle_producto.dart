import 'package:flutter/material.dart';
import '/models/producto.dart';
import 'pantalla_escaneo.dart';
import 'agregar_producto.dart'; // Importamos el formulario

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
    final codigoScanned = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const PantallaEscaneo()));
    if (codigoScanned != null && mounted) {
      setState(() {
        _prod.codigoBarras = codigoScanned;
      });
      widget.onEditar(_prod);
    }
  }

  // --- NUEVA FUNCIÓN PARA ABRIR EL FORMULARIO EN MODO EDICIÓN ---
  void _abrirFormularioEdicion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) => AgregarProductoForm(
        productoAEditar:
            _prod, // Le pasamos el producto actual para que prellene los campos
        onGuardar: (productoEditado) {
          setState(() {
            _prod = productoEditado; // Actualizamos la vista local
          });
          widget.onEditar(
            productoEditado,
          ); // Mandamos la orden de actualización a la nube
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              widget.onBorrar(_prod.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'comprado',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _prod.comprado ? 'Y' : 'N',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Checkbox(
                        value: _prod.comprado,
                        onChanged: (val) {
                          setState(() => _prod.comprado = val ?? false);
                          widget.onEditar(_prod);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2C2C2C), height: 32),
                  const Text(
                    'Producto',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _prod.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Color(0xFF2C2C2C), height: 32),
                  const Text(
                    'Cantidad',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_prod.cantidad}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Color(0xFF2C2C2C), height: 32),
                  const Text(
                    'Precio Unitario',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_prod.precioUnitario.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Color(0xFF2C2C2C), height: 32),
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_prod.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD49EEB),
                    ),
                  ),
                  const Divider(color: Color(0xFF2C2C2C), height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Código de Barras',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _prod.codigoBarras ?? 'No asignado',
                            style: TextStyle(
                              fontSize: 16,
                              color: _prod.codigoBarras == null
                                  ? Colors.grey
                                  : Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Color(0xFFD49EEB),
                          size: 28,
                        ),
                        onPressed: _vincularCodigoBarras,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=100',
                ),
                opacity: 0.04,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ],
      ),
      // --- AGREGAMOS EL BOTÓN FLOTANTE DE EDICIÓN ---
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioEdicion,
        child: const Icon(Icons.edit, size: 28),
      ),
    );
  }
}
