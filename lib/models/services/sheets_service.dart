import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/models/producto.dart';

class SheetsService {
  // Usamos una constante que puede ser inyectada al compilar con --dart-define
  // Si no se inyecta, usa la URL por defecto (pero no se recomienda para Git publico)
  static const String _urlWebDeployment = String.fromEnvironment(
    'SHEETS_URL',
    defaultValue: 'https://script.google.com/macros/s/AKfycbwj_qIIFUOhpCFpHaH4IAtE6v0AemV_QCuGtKuoXPoCt567DVPRh7dWKswwcJqPpr0A/exec',
  );

  static Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await http.get(Uri.parse(_urlWebDeployment));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((jsonItem) => Producto.fromJson(jsonItem)).toList();
      } else {
        debugPrint('Error en el servidor: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error al obtener productos: $e');
      return [];
    }
  }

  static Future<bool> enviarAccion(Producto producto, String accion) async {
    try {
      final response = await http.post(
        Uri.parse(_urlWebDeployment),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': accion,
          'id': producto.id,
          'nombre': producto.nombre,
          'cantidad': producto.cantidad,
          'precioUnitario': producto.precioUnitario, // <-- Actualizado
          'categoria': producto.categoria,
          'comprado': producto.comprado,
          'codigoBarras': producto.codigoBarras,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al enviar accion: $e');
      return false;
    }
  }
  static Future<double> obtenerTotalHistorial() async {
    try {
      // Le pasamos el "?tipo=historial" al final del link
      final response = await http.get(
        Uri.parse('$_urlWebDeployment?tipo=historial'),
      );

      if (response.statusCode == 200) {
        return double.tryParse(response.body) ?? 0.0;
      }
    } catch (e) {
      debugPrint('Error al obtener historial: $e');
    }
    return 0.0;
  }
  static Future<void> hacerBackupEnDrive(String historialJson) async {
    try {
      final payload = {
        'accion': 'BACKUP',
        'historial':
            historialJson, // Pasamos todo el historial convertido a texto
      };

      await http.post(
        Uri.parse(_urlWebDeployment),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      debugPrint('Backup enviado con exito a Drive');
    } catch (e) {
      debugPrint('Error al enviar backup a Drive: $e');
    }
  }
}
