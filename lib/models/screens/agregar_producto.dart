import 'package:flutter/material.dart';
import '/models/producto.dart';
import 'pantalla_escaneo.dart';

class AgregarProductoForm extends StatefulWidget {
  final Producto? productoAEditar;
  final String? codigoBarrasPrellenado;
  final String? nombrePrellenado;
  final String? categoriaPrellenada;
  final Function(Producto) onGuardar;

  const AgregarProductoForm({
    super.key,
    this.productoAEditar,
    this.codigoBarrasPrellenado,
    this.nombrePrellenado,
    this.categoriaPrellenada,
    required this.onGuardar,
  });

  @override
  State<AgregarProductoForm> createState() => _AgregarProductoFormState();
}

class _AgregarProductoFormState extends State<AgregarProductoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  int _cantidad = 1;
  String _categoriaSeleccionada = 'Almacén';
  String? _codigoBarras;

  final List<String> _categorias = [
    'Almacén',
    'Lácteos',
    'Carnicería',
    'Verdulería',
    'Limpieza',
    'Bebidas',
    'Panadería',
    'Frescos',
    'Mascotas',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.productoAEditar?.nombre ?? widget.nombrePrellenado ?? '',
    );
    _precioController = TextEditingController(
      text: widget.productoAEditar != null
          ? widget.productoAEditar!.precioUnitario.toString()
          : '',
    );
    _cantidad = widget.productoAEditar?.cantidad ?? 1;
    _categoriaSeleccionada =
        widget.productoAEditar?.categoria ??
        widget.categoriaPrellenada ??
        'Almacén';
    _codigoBarras =
        widget.productoAEditar?.codigoBarras ?? widget.codigoBarrasPrellenado;
  }

  // --- NUEVA FUNCIÓN PARA ESCANEAR DIRECTO DESDE EL FORMULARIO ---
  Future<void> _escanearCodigo() async {
    final codigoScanned = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const PantallaEscaneo()));
    if (codigoScanned != null && mounted) {
      setState(() {
        _codigoBarras = codigoScanned;
      });
      // Mensajito de éxito opcional
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código vinculado con éxito'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _enviarDatos() {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final precio = double.tryParse(_precioController.text) ?? 0.0;

      final producto = Producto(
        id:
            widget.productoAEditar?.id ??
            'PROD_${DateTime.now().millisecondsSinceEpoch}',
        nombre: nombre,
        precioUnitario: precio,
        cantidad: _cantidad,
        categoria: _categoriaSeleccionada,
        codigoBarras: _codigoBarras,
        comprado: widget.productoAEditar?.comprado ?? false,
      );

      widget.onGuardar(producto);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- NUEVA CABECERA CON EL TÍTULO Y EL BOTÓN DE ESCANEAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.productoAEditar == null
                      ? 'Agregar Producto'
                      : 'Editar Producto',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  // Si ya hay un código, el botón se pone verde para avisarte
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: _codigoBarras != null
                        ? Colors.green
                        : const Color(0xFFD49EEB),
                    size: 30,
                  ),
                  onPressed: _escanearCodigo,
                ),
              ],
            ),

            // Si escaneó algo, mostramos el numerito chiquito abajo del botón
            if (_codigoBarras != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Código: $_codigoBarras',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // --- RESTO DEL FORMULARIO INTACTO ---
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categorias.contains(_categoriaSeleccionada)
                  ? _categoriaSeleccionada
                  : 'Otros',
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: _categorias
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio Unitario \$',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setState(() {
                        if (_cantidad > 1) _cantidad--;
                      }),
                    ),
                    Text('$_cantidad', style: const TextStyle(fontSize: 20)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _cantidad++),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD49EEB),
                  foregroundColor: Colors.black,
                ),
                onPressed: _enviarDatos,
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
