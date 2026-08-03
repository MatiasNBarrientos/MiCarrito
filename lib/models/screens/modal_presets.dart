import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/producto.dart';

class ModalPresets extends StatefulWidget {
  final Function(Producto) onAgregar;
  const ModalPresets({super.key, required this.onAgregar});

  @override
  State<ModalPresets> createState() => _ModalPresetsState();
}

class _ModalPresetsState extends State<ModalPresets> {
  List<Map<String, dynamic>> _presets = [];

  @override
  void initState() {
    super.initState();
    _cargarPresets();
  }

  Future<void> _cargarPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? guardados = prefs.getString('presets_productos');

    if (guardados != null) {
      setState(() {
        _presets = List<Map<String, dynamic>>.from(jsonDecode(guardados));
      });
    } else {
      // Autocarga de los básicos si está vacío
      setState(() {
        _presets = [
          {
            'nombre': 'Yerba Mate',
            'precio': 0.0,
            'categoria': 'Almacén',
          },
          {
            'nombre': 'Harina',
            'precio': 1200.0,
            'categoria': 'Almacén',
          },
          {
            'nombre': 'Leche',
            'precio': 0.0,
            'categoria': 'Lácteos',
          },
          {
            'nombre': 'Papas',
            'precio': 0.0,
            'categoria': 'Verdulería',
          },
          {
            'nombre': 'Papel Higiénico',
            'precio': 0.0,
            'categoria': 'Limpieza',
          },
          {
            'nombre': 'Arroz',
            'precio': 0.0,
            'categoria': 'Almacén',
          },
          {
            'nombre': 'Detergente',
            'precio': 0.0,
            'categoria': 'Limpieza',
          },
        ];
      });
      await _guardarPresets();
    }
  }

  Future<void> _guardarPresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('presets_productos', jsonEncode(_presets));
  }

  // ==========================================================
  // PANEL 1: CONFIRMAR PRECIO (Evita el bloqueo del teclado)
  // ==========================================================
  void _mostrarDialogoConfirmarAgregar(Map<String, dynamic> preset, int index) {
    final precioCtrl = TextEditingController(text: preset['precio'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Fundamental para empujar el teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            ctx,
          ).viewInsets.bottom, // Padding dinámico del teclado
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmar: ${preset['nombre']}',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF6A1B9A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ajustá el precio de la góndola:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: precioCtrl,
              autofocus: true, // Abre el teclado automáticamente
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Precio Actual (\$)',
                prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Reemplaza coma por punto por si tecleaste mal
                  final nuevoPrecio =
                      double.tryParse(precioCtrl.text.replaceAll(',', '.')) ??
                      0.0;

                  setState(() => _presets[index]['precio'] = nuevoPrecio);
                  _guardarPresets();

                  final nuevoProducto = Producto(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nombre: preset['nombre'],
                    precioUnitario: nuevoPrecio,
                    categoria: preset['categoria'],
                    cantidad: 1,
                  );

                  Navigator.pop(ctx); // Cierra este mini panel
                  widget.onAgregar(nuevoProducto); // Lo manda al Excel
                  Navigator.pop(context); // Cierra el panel de presets de fondo
                },
                child: const Text(
                  'Al Carrito',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  // ==========================================================
  // PANEL 2: CREAR PRESET (Evita el bloqueo del teclado)
  // ==========================================================
  void _mostrarDialogoCrearPreset() {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    String categoriaSelec = 'Almacén';
    final categorias = [
      'Almacén',
      'Lácteos',
      'Verdulería',
      'Carnicería',
      'Limpieza',
      'Otros',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
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
              const SizedBox(height: 15),
              const Text(
                'Nuevo Producto Frecuente',
                style: TextStyle(
                  color: Color(0xFF6A1B9A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nombreCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nombre (Ej: Leche)',
                  prefixIcon: const Icon(Icons.star),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Precio Aprox (\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: categoriaSelec,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) categoriaSelec = val;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (nombreCtrl.text.isNotEmpty) {
                      setState(() {
                        _presets.add({
                          'nombre': nombreCtrl.text,
                          'precio':
                              double.tryParse(
                                precioCtrl.text.replaceAll(',', '.'),
                              ) ??
                              0.0,
                          'categoria': categoriaSelec,
                        });
                      });
                      _guardarPresets();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text(
                    'Guardar Preset',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 15),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text(
                'Productos Frecuentes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _presets.isEmpty
                ? const Center(
                    child: Text(
                      'Todavía no agregaste favoritos.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _presets.length,
                    itemBuilder: (context, index) {
                      final preset = _presets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFF3E5F5),
                            child: Icon(
                              Icons.add_shopping_cart,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          title: Text(
                            preset['nombre'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${preset['categoria']} • \$${preset['precio']}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() => _presets.removeAt(index));
                              _guardarPresets();
                            },
                          ),
                          onTap: () =>
                              _mostrarDialogoConfirmarAgregar(preset, index),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'CREAR NUEVO PRESET',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _mostrarDialogoCrearPreset,
            ),
          ),
        ],
      ),
    );
  }
}
