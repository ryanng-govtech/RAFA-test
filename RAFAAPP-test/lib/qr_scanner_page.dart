import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rafa_app/main.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('QR Scanner'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state as CameraFacing) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) {
              final String? url = barcode.rawValue;
              debugPrint('Barcode found! $url');

              //retrieve parameters from url
              if (url != null) {
                var uri = Uri.dataFromString(url);
                Map<String, String>? params =
                    Map.fromEntries(uri.queryParameters.entries);
                for (String key in params.keys) {
                  if (params[key] != null) {
                    if (params[key]!.contains("#/")) {
                      String lastParam = params[key]!.split("#/").first;
                      params[key] = lastParam;
                    }
                  }
                }
                if (params["building"] != null) {
                  params["building"] = urlDecoding(params["building"]!);
                }
                if (params["spaceid"] != null) {
                  spaceId = urlDecoding(params["spaceid"]!);
                }
                if (params["space"] != null) {
                  params["space"] = urlDecoding(params["space"]!);
                }

                setState(() {
                  Navigator.pop(context, params);
                });
              }
            }));
  }
}
