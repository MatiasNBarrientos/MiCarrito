import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/producto.dart';

class SheetsService {
  // ACA PEGA TU URL DE APPS SCRIPT
  static const String _urlWebApp = 'https://script.google.com/macros/s/AKfycbwj_qIIFUOhpCFpHaH4IAtE6v0AemV_QCuGtKuoXPoCt567DVPRh7dWKswwcJqPpr0A/exec';

  // 1. OBTENER PRODUCTOS: Intenta de la nube, si falla, carga el caché
  static Future<List<Producto>> obtenerProductos() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .get(Uri.parse(_urlWebApp))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> datosJson = json.decode(response.body);
        final productosNube = datosJson
            .map((json) => Producto.fromJson(json))
            .toList();
        return productosNube;
      }
    } catch (e) {
      print("Sin conexión: No se pudo obtener de Sheets.");
    }

    // Si falló internet, cargamos la memoria del celular
    final String? datosLocales = prefs.getString('productos_locales');
    if (datosLocales != null) {
      final List<dynamic> datosJson = json.decode(datosLocales);
      return datosJson.map((json) => Producto.fromJson(json)).toList();
    }
    return [];
  }

  // 2. ENVIAR ACCIÓN: Intenta subir a la nube, si falla, va a la cola
  static Future<void> enviarAccion(Producto producto, String accion) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> payload = {
      "action": accion,
      "id": producto.id,
      "nombre": producto.nombre,
      "precioUnitario": producto.precioUnitario,
      "cantidad": producto.cantidad,
      "categoria": producto.categoria,
      "codigoBarras": producto.codigoBarras ?? "",
      "comprado": producto.comprado,
    };

    try {
      final response = await http
          .post(Uri.parse(_urlWebApp), body: json.encode(payload))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return; // Éxito total
    } catch (e) {
      print("Sin internet: Acción guardada en cola local.");
    }

    // Guardamos en la cola local para enviarlo después
    final String? colaString = prefs.getString('cola_acciones');
    List<dynamic> cola = colaString != null ? json.decode(colaString) : [];
    cola.add(payload);
    await prefs.setString('cola_acciones', json.encode(cola));
  }

  // 3. SINCRONIZADOR: Intenta subir todo lo que haya quedado atascado
  static Future<void> sincronizarPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? colaString = prefs.getString('cola_acciones');

    if (colaString == null) return;

    List<dynamic> cola = json.decode(colaString);
    if (cola.isEmpty) return;

    List<dynamic> noEnviados = [];

    for (var accion in cola) {
      try {
        final response = await http
            .post(Uri.parse(_urlWebApp), body: json.encode(accion))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode != 200) {
          noEnviados.add(
            accion,
          ); // Falló el server, lo guardamos para intentar más tarde
        }
      } catch (e) {
        noEnviados.add(accion); // Sigue sin internet
      }
    }

    if (noEnviados.isEmpty) {
      await prefs.remove('cola_acciones'); // Limpiamos la cola si todo se envió
    } else {
      await prefs.setString('cola_acciones', json.encode(noEnviados));
    }
  }
}
