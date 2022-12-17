import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  static const routeName = '/scanQR';

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? result;
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    controller.scannedDataStream.listen((scanData) {
      setState(() => result = scanData);
    });
  }

  void readQr() async {
    if (result != null) {
      await controller!.pauseCamera();
      controller!.dispose();
      Get.offAndToNamed('/boltz-auth', arguments: {"auth": result!.code});
      // Get.toNamed('/boltz-auth', arguments: {"auth": result!.code});
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => readQr());
    return Scaffold(
        appBar: AppBar(
          title: Text("Boltz Authentication"),
          centerTitle: true,
        ),
        body: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.orange,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: 250,
          ),
        ));
  }
}
