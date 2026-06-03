class Producto {
  String id;
  String nombre;
  double precioUnitario;
  int cantidad;
  String categoria;
  String? codigoBarras;
  bool comprado;

  Producto({
    required this.id,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    required this.categoria,
    this.codigoBarras,
    this.comprado = false,
  });

  double get subtotal => precioUnitario * cantidad;

  // Convierte el objeto a texto para guardarlo en la memoria del celular
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'precioUnitario': precioUnitario,
    'cantidad': cantidad,
    'categoria': categoria,
    'codigoBarras': codigoBarras,
    'comprado': comprado,
  };

  // Convierte el texto guardado de vuelta a un objeto Producto
  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json['id'].toString(),
    nombre: json['nombre'] ?? '',
    precioUnitario: double.tryParse(json['precioUnitario'].toString()) ?? 0.0,
    cantidad: int.tryParse(json['cantidad'].toString()) ?? 1,
    categoria: json['categoria'] ?? 'Otros',
    codigoBarras: json['codigoBarras']?.toString(),
    comprado: json['comprado'].toString().toLowerCase() == 'true',
  );
}
