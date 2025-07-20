import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../../../domain/services/scanning/core/image_cropper_service.dart';

/// Implementación del servicio de recorte de imágenes
/// Usa la librería 'image' para procesamiento local
class ImageCropperServiceImpl implements ImageCropperService {
  @override
  Future<CropResult> cropToOverlay({
    required File originalImage,
    required OverlayBounds bounds,
  }) async {
    try {
      final imageBytes = await originalImage.readAsBytes();
      return await cropFromBytes(imageBytes: imageBytes, bounds: bounds);
    } catch (e) {
      return CropResult.error('Error al leer archivo: $e');
    }
  }

  @override
  Future<CropResult> cropFromBytes({
    required Uint8List imageBytes,
    required OverlayBounds bounds,
  }) async {
    try {
      // Decodificar imagen
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return CropResult.error('No se pudo decodificar la imagen');
      }

      debugPrint('🖼️ Imagen de cámara original: ${image.width}x${image.height}');
      debugPrint('📐 Screen bounds: ${bounds.screenWidth}x${bounds.screenHeight}');
      debugPrint('📐 Overlay bounds: ${bounds.width}x${bounds.height} at (${bounds.left}, ${bounds.top})');

      // Calcular coordenadas de recorte basadas en el overlay
      final cropCoords = _calculateCropCoordinates(image, bounds);
      
      debugPrint('✂️ Coordenadas de recorte: x=${cropCoords.x}, y=${cropCoords.y}, w=${cropCoords.width}, h=${cropCoords.height}');

      // Recortar imagen
      final croppedImage = img.copyCrop(
        image,
        x: cropCoords.x,
        y: cropCoords.y,
        width: cropCoords.width,
        height: cropCoords.height,
      );

      debugPrint('✅ Imagen recortada final: ${croppedImage.width}x${croppedImage.height}');

      // Convertir a bytes
      final croppedBytes = img.encodeJpg(croppedImage, quality: 90);
      
      debugPrint('📦 Bytes de imagen recortada: ${croppedBytes.length}');
      
      return CropResult.success(Uint8List.fromList(croppedBytes));
    } catch (e) {
      return CropResult.error('Error al recortar imagen: $e');
    }
  }

  @override
  Future<CropResult> enhanceForOCR(Uint8List croppedImage) async {
    try {
      final image = img.decodeImage(croppedImage);
      if (image == null) {
        return CropResult.error('No se pudo decodificar imagen para mejorar');
      }

      // Aplicar mejoras para OCR
      var enhanced = image;
      
      // Aumentar contraste para mejor legibilidad
      enhanced = img.contrast(enhanced, contrast: 1.2);
      
      // Ajustar brillo ligeramente  
      enhanced = img.adjustColor(enhanced, brightness: 1.1);
      
      // Redimensionar si es muy pequeña (mínimo 400px ancho para OCR)
      if (enhanced.width < 400) {
        final scale = 400 / enhanced.width;
        enhanced = img.copyResize(
          enhanced,
          width: 400,
          height: (enhanced.height * scale).round(),
          interpolation: img.Interpolation.cubic,
        );
      }

      final enhancedBytes = img.encodeJpg(enhanced, quality: 95);
      return CropResult.success(Uint8List.fromList(enhancedBytes));
    } catch (e) {
      return CropResult.error('Error al mejorar imagen: $e');
    }
  }

  /// Calcula las coordenadas de recorte basadas en el overlay y la imagen real
  _CropCoordinates _calculateCropCoordinates(
    img.Image image,
    OverlayBounds bounds,
  ) {
    // Calcular la escala entre la imagen real y la pantalla
    final scaleX = image.width / bounds.screenWidth;
    final scaleY = image.height / bounds.screenHeight;

    // Convertir coordenadas del overlay a coordenadas de imagen
    final x = (bounds.left * scaleX).round();
    final y = (bounds.top * scaleY).round();
    final width = (bounds.width * scaleX).round();
    final height = (bounds.height * scaleY).round();

    // Asegurar que no se salga de los límites de la imagen
    final clampedX = x.clamp(0, image.width - 1);
    final clampedY = y.clamp(0, image.height - 1);
    final clampedWidth = (width).clamp(1, image.width - clampedX);
    final clampedHeight = (height).clamp(1, image.height - clampedY);

    return _CropCoordinates(
      x: clampedX,
      y: clampedY,
      width: clampedWidth,
      height: clampedHeight,
    );
  }
}

/// Coordenadas de recorte calculadas
class _CropCoordinates {
  final int x;
  final int y;
  final int width;
  final int height;

  const _CropCoordinates({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
} 