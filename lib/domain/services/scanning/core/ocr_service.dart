import 'dart:typed_data';

/// Resultado del OCR con información de confianza
class OCRResult {
  final String extractedText;
  final double confidence; // 0.0 - 1.0
  final bool success;
  final String? error;
  final List<String> candidateNames; // Posibles nombres detectados

  const OCRResult({
    required this.extractedText,
    required this.confidence,
    required this.success,
    this.error,
    this.candidateNames = const [],
  });

  factory OCRResult.success({
    required String text,
    required double confidence,
    List<String> candidates = const [],
  }) {
    return OCRResult(
      extractedText: text,
      confidence: confidence,
      success: true,
      candidateNames: candidates,
    );
  }

  factory OCRResult.error(String error) {
    return OCRResult(
      extractedText: '',
      confidence: 0.0,
      success: false,
      error: error,
    );
  }

  /// Indica si la confianza es suficiente para proceder automáticamente
  bool get isHighConfidence => confidence >= 0.8;

  /// Indica si necesita fallback manual
  bool get needsManualFallback => confidence < 0.5;
}

/// Configuración para el OCR
class OCRConfig {
  final bool enhanceContrast;
  final bool removeBackground;
  final bool focusOnNameRegion;
  final double minConfidenceThreshold;

  const OCRConfig({
    this.enhanceContrast = true,
    this.removeBackground = false,
    this.focusOnNameRegion = true,
    this.minConfidenceThreshold = 0.5,
  });

  /// Configuración optimizada para cartas MTG (SIN filtros destructivos)
  static const OCRConfig mtgOptimized = OCRConfig(
    enhanceContrast: false, // ❌ Los filtros destruían el texto legible
    removeBackground: false,
    focusOnNameRegion: true,
    minConfidenceThreshold: 0.6,
  );

  /// Configuración con filtros agresivos (LEGACY - causaba problemas)
  static const OCRConfig mtgWithFilters = OCRConfig(
    enhanceContrast: true,
    removeBackground: false,
    focusOnNameRegion: true,
    minConfidenceThreshold: 0.6,
  );
}

/// Servicio para extraer texto (especialmente nombres) de cartas MTG
/// Siguiendo Single Responsibility Principle
abstract class OCRService {
  /// Extrae el nombre de la carta de la imagen recortada
  Future<OCRResult> extractCardName(
    Uint8List croppedImage, {
    OCRConfig config = OCRConfig.mtgOptimized,
  });

  /// Extrae todo el texto visible en la carta
  Future<OCRResult> extractAllText(
    Uint8List croppedImage, {
    OCRConfig config = OCRConfig.mtgOptimized,
  });

  /// Limpia y normaliza el texto extraído para búsquedas
  String normalizeCardName(String rawText);

  /// Verifica si el texto parece ser un nombre de carta válido
  bool isValidCardName(String text);

  /// Test con imagen local de alta calidad (solo para debugging)
  Future<void> testWithLocalImage(String imagePath);
} 