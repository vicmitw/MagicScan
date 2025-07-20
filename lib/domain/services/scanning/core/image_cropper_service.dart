import 'dart:io';
import 'dart:typed_data';

/// Bounds del overlay para recorte preciso
class OverlayBounds {
  final double left;
  final double top;
  final double width;
  final double height;
  final double screenWidth;
  final double screenHeight;

  const OverlayBounds({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.screenWidth,
    required this.screenHeight,
  });
}

/// Resultado del recorte de imagen
class CropResult {
  final Uint8List croppedImageBytes;
  final bool success;
  final String? error;

  const CropResult({
    required this.croppedImageBytes,
    required this.success,
    this.error,
  });

  factory CropResult.success(Uint8List imageBytes) {
    return CropResult(
      croppedImageBytes: imageBytes,
      success: true,
    );
  }

  factory CropResult.error(String error) {
    return CropResult(
      croppedImageBytes: Uint8List(0),
      success: false,
      error: error,
    );
  }
}

/// Servicio para recortar imágenes usando los bounds del overlay
/// Siguiendo Single Responsibility Principle
abstract class ImageCropperService {
  /// Recorta la imagen usando los bounds del overlay de la cámara
  Future<CropResult> cropToOverlay({
    required File originalImage,
    required OverlayBounds bounds,
  });

  /// Recorta desde bytes de imagen directamente
  Future<CropResult> cropFromBytes({
    required Uint8List imageBytes,
    required OverlayBounds bounds,
  });

  /// Procesa y mejora la imagen recortada para OCR
  Future<CropResult> enhanceForOCR(Uint8List croppedImage);
} 