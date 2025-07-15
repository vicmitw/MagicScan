import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../models/scanned_card.dart';
import '../models/scan_result.dart';

/// Servicio para manejo de cámara y reconocimiento de cartas
class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();

  CameraService._();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;

  final _textRecognizer = TextRecognizer();

  /// Inicializa el servicio de cámara
  Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();

      if (_cameras?.isEmpty ?? true) {
        debugPrint('No se encontraron cámaras disponibles');
        return false;
      }

      // Usar la cámara trasera por defecto
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;

      debugPrint('Servicio de cámara inicializado correctamente');
      return true;
    } catch (e) {
      debugPrint('Error al inicializar cámara: $e');
      return false;
    }
  }

  /// Obtiene el controlador de cámara
  CameraController? get controller => _controller;

  /// Indica si la cámara está inicializada
  bool get isInitialized =>
      _isInitialized && (_controller?.value.isInitialized ?? false);

  /// Indica si está escaneando activamente
  bool get isScanning => _isScanning;

  /// Inicia el modo de escaneo continuo
  void startScanning() {
    _isScanning = true;
  }

  /// Detiene el modo de escaneo continuo
  void stopScanning() {
    _isScanning = false;
  }

  /// Captura una imagen y la procesa para detectar cartas
  Future<ScanResult> captureAndProcess(ScanType scanType) async {
    if (!isInitialized || _controller == null) {
      return ScanResult.error(
        error: 'Cámara no inicializada',
        scanType: scanType,
      );
    }

    try {
      // Capturar imagen
      final XFile image = await _controller!.takePicture();

      // Procesar imagen para reconocimiento
      final result = await _processImage(image.path, scanType);

      return result;
    } catch (e) {
      debugPrint('Error al capturar imagen: $e');
      return ScanResult.error(
        error: 'Error al capturar imagen: $e',
        scanType: scanType,
      );
    }
  }

  /// Procesa una imagen para reconocer texto de cartas MTG
  Future<ScanResult> _processImage(String imagePath, ScanType scanType) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Procesar texto reconocido para extraer información de carta
      final cardInfo = _extractCardInfo(recognizedText.text);

      if (cardInfo != null) {
        return ScanResult.success(card: cardInfo, scanType: scanType);
      } else {
        return ScanResult.error(
          error: 'No se pudo reconocer información de carta',
          scanType: scanType,
        );
      }
    } catch (e) {
      debugPrint('Error al procesar imagen: $e');
      return ScanResult.error(
        error: 'Error al procesar imagen: $e',
        scanType: scanType,
      );
    }
  }

  /// Extrae información de carta del texto reconocido
  ScannedCard? _extractCardInfo(String recognizedText) {
    if (recognizedText.isEmpty) return null;

    // Por ahora, simular reconocimiento para desarrollo
    // En producción, aquí iría la lógica real de OCR y matching con base de datos

    // Lista de cartas simuladas para pruebas
    final mockCards = [
      ScannedCard(
        name: 'Lightning Bolt',
        type: 'Instant',
        set: 'Magic 2011',
        rarity: 'common',
        imageUrl: 'assets/images/prueba_carta.png',
        price: 0.25,
        priceFormatted: '\$0.25',
        confidence: 0.95,
      ),
      ScannedCard(
        name: 'Counterspell',
        type: 'Instant',
        set: 'Magic 2010',
        rarity: 'common',
        imageUrl: 'assets/images/prueba_carta.png',
        price: 0.15,
        priceFormatted: '\$0.15',
        confidence: 0.92,
      ),
      ScannedCard(
        name: 'Black Lotus',
        type: 'Artifact',
        set: 'Alpha',
        rarity: 'rare',
        imageUrl: 'assets/images/prueba_carta.png',
        price: 27500.00,
        priceFormatted: '\$27,500.00',
        confidence: 0.98,
      ),
      ScannedCard(
        name: 'Obeka, Brute Chronologist',
        type: 'Legendary Creature — Ogre Wizard',
        set: 'Commander Legends',
        rarity: 'rare',
        imageUrl: 'assets/images/prueba_carta.png',
        price: 0.68,
        priceFormatted: '\$0.68',
        confidence: 0.89,
      ),
    ];

    // Simular detección aleatoria
    final random = DateTime.now().millisecondsSinceEpoch % mockCards.length;
    return mockCards[random];
  }

  /// Obtiene una vista previa optimizada para reconocimiento
  Future<Uint8List?> getOptimizedPreview() async {
    if (!isInitialized || _controller == null) return null;

    try {
      final image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();

      // Optimizar imagen para reconocimiento
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      // Redimensionar para optimizar procesamiento
      final resized = img.copyResize(decodedImage, width: 800);

      // Mejorar contraste para mejor reconocimiento
      final enhanced = img.adjustColor(resized, contrast: 1.2, brightness: 0.1);

      return Uint8List.fromList(img.encodeJpg(enhanced));
    } catch (e) {
      debugPrint('Error al obtener vista previa: $e');
      return null;
    }
  }

  /// Verifica si hay una carta en el marco de captura
  Future<bool> hasCardInFrame() async {
    if (!isInitialized) return false;

    try {
      final preview = await getOptimizedPreview();
      if (preview == null) return false;

      // Simulación de detección de carta en frame
      // En producción, aquí iría detección de bordes/contornos
      return true;
    } catch (e) {
      debugPrint('Error al verificar carta en frame: $e');
      return false;
    }
  }

  /// Cambia entre cámaras frontal y trasera
  Future<bool> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return false;

    try {
      final currentLens = _controller?.description.lensDirection;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentLens,
        orElse: () => _cameras!.first,
      );

      await _controller?.dispose();

      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      return true;
    } catch (e) {
      debugPrint('Error al cambiar cámara: $e');
      return false;
    }
  }

  /// Configura el flash
  Future<void> setFlashMode(FlashMode mode) async {
    if (!isInitialized) return;

    try {
      await _controller?.setFlashMode(mode);
    } catch (e) {
      debugPrint('Error al configurar flash: $e');
    }
  }

  /// Libera recursos
  Future<void> dispose() async {
    try {
      _isScanning = false;
      await _controller?.dispose();
      await _textRecognizer.close();
      _controller = null;
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error al liberar recursos: $e');
    }
  }
}
