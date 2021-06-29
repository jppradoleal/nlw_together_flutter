import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nlw_together/modules/barcode_scanner/barcode_scanner_status.dart';

class BarcodeScannerController {
  final statusNotifier =
      ValueNotifier<BarcodeScannerStatus>(BarcodeScannerStatus());

  BarcodeScannerStatus get status => statusNotifier.value;
  set status(BarcodeScannerStatus status) => statusNotifier.value = status;

  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  CameraController? cameraController;

  void getAvailableCameras() async {
    try {
      final response = await availableCameras();
      final camera = response.firstWhere(
        (element) => element.lensDirection == CameraLensDirection.back,
      );
      cameraController = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await cameraController!.initialize();
      scanWithCamera();
      listenCamera();
    } catch (e) {
      status = BarcodeScannerStatus.error(e.toString());
    }
  }

  void scanWithCamera() {
    status = BarcodeScannerStatus.available();
    Future.delayed(Duration(seconds: 20)).then((value) {
      if (status.hasBarcode == false) {
        status = BarcodeScannerStatus.error("Timeout de leitura de boleto");
      }
    });
  }

  Future<void> scannerBarCode(InputImage inputImage) async {
    try {
      final barcodes = await barcodeScanner.processImage(inputImage);
      var barcode;

      for (Barcode item in barcodes) {
        barcode = item.value.displayValue;
      }

      if (barcode != null && status.barcode.isEmpty) {
        status = BarcodeScannerStatus.barcode(barcode);
        cameraController!.dispose();
        await barcodeScanner.close();
      }

      return;
    } catch (e) {
      print(e);
    }
  }

  void scanWithImagePicker() async {
    final response = await ImagePicker().getImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(response!.path);
    scannerBarCode(inputImage);
  }

  void listenCamera() {
    if (cameraController!.value.isStreamingImages == false)
      cameraController!.startImageStream(
        (image) async {
          if (status.stopScanner == false) {
            try {
              final WriteBuffer allBytes = WriteBuffer();
              for (Plane plane in image.planes) {
                allBytes.putUint8List(plane.bytes);
              }

              final bytes = allBytes.done().buffer.asUint8List();
              final Size imageSize =
                  Size(image.width.toDouble(), image.height.toDouble());
              final InputImageRotation imageRotation =
                  InputImageRotation.Rotation_0deg;
              final InputImageFormat inputImageFormat =
                  InputImageFormatMethods.fromRawValue(image.format.raw) ??
                      InputImageFormat.NV21;
              final planeData = image.planes.map((Plane plane) {
                return InputImagePlaneMetadata(
                  bytesPerRow: plane.bytesPerRow,
                  height: plane.height,
                  width: plane.width,
                );
              }).toList();

              final inputImageData = InputImageData(
                size: imageSize,
                imageRotation: imageRotation,
                inputImageFormat: inputImageFormat,
                planeData: planeData,
              );

              final inputImageCamera = InputImage.fromBytes(
                bytes: bytes,
                inputImageData: inputImageData,
              );

              await scannerBarCode(inputImageCamera);
            } catch (e) {
              print(e);
            }
          }
        },
      );
  }

  void dispose() {
    statusNotifier.dispose();
    barcodeScanner.close();
    if (status.showCamera) {
      cameraController!.dispose();
    }
  }
}
