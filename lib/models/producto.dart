class Producto {
  String id;
  String nombre;
  int cantidad;
  double precioUnitario; // <-- Actualizado
  String categoria;
  bool comprado;
  String? codigoBarras;

  Producto({
    String? id,
    required this.nombre,
    this.cantidad = 1,
    this.precioUnitario = 0.0,
    required this.categoria,
    this.comprado = false,
    this.codigoBarras,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get subtotal => cantidad * precioUnitario;

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id']?.toString(),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      cantidad: int.tryParse(json['cantidad']?.toString() ?? '1') ?? 1,
      // Leemos 'precioUnitario' directo desde la API
      precioUnitario:
          double.tryParse(
            json['precioUnitario']?.toString() ??
                json['precio']?.toString() ??
                '0.0',
          ) ??
          0.0,
      categoria: json['categoria']?.toString() ?? 'Otros',
      comprado: json['comprado'] == true || json['comprado'] == 'true',
      codigoBarras: json['codigoBarras']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'categoria': categoria,
      'comprado': comprado,
      'codigoBarras': codigoBarras ?? '',
    };
  }
}
