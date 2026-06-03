import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PantallaEscaneo extends StatefulWidget {
  const PantallaEscaneo({super.key});

  @override
  State<PantallaEscaneo> createState() => _PantallaEscaneoState();
}

class _PantallaEscaneoState extends State<PantallaEscaneo> {
  // Controlador de la cámara moderno
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _escaneado =
      false; // Candado para evitar que lea el mismo código 50 veces por segundo
  bool _torchEnabled = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear Código'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Botón de Linterna
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              cameraController.toggleTorch();
              setState(() {
                _torchEnabled = !_torchEnabled;
              });
            },
          ),
          // Botón para rotar cámara
          IconButton(
            icon: Icon(
              _cameraFacing == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear,
            ),
            onPressed: () {
              cameraController.switchCamera();
              setState(() {
                _cameraFacing = _cameraFacing == CameraFacing.back
                    ? CameraFacing.front
                    : CameraFacing.back;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // La vista de la cámara
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_escaneado) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    setState(() {
                      _escaneado = true; // Bloqueamos nuevas lecturas
                    });
                    final String code = barcode.rawValue!;
                    // Detenemos la cámara por rendimiento antes de salir
                    cameraController.stop();
                    Navigator.of(
                      context,
                    ).pop(code); // Devolvemos el código a la lista
                    break;
                  }
                }
              }
            },
          ),

          // --- DISEÑO VISUAL: RECUADRO DE ESCANEO ---
          // Oscurece los bordes para resaltar el centro
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 300,
                      height: 150, // Rectangular, ideal para códigos de barras
                      decoration: BoxDecoration(
                        color: Colors.black, // Color clave para el BlendMode
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Borde Lila alrededor de la zona de escaneo
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 300,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD49EEB), width: 3),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // Texto indicativo abajo
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Text(
                'Alineá el código de barras en el recuadro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Apagamos la cámara al salir de la pantalla para ahorrar batería
    cameraController.dispose();
    super.dispose();
  }
}
