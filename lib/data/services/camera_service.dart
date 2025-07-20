import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/scanned_card.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/services/scanning/core/image_cropper_service.dart';
import '../../domain/services/scanning/core/ocr_service.dart';
import 'scanning/image_cropper_service_impl.dart';
import 'scanning/ocr_service_impl.dart';

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
  
  // Motor de scanning real
  final ImageCropperService _imageCropper = ImageCropperServiceImpl();
  final OCRService _ocrService = OCRServiceImpl();

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
      
      // Configurar autofocus continuo para mejor nitidez en lectura de texto
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
      
      _isInitialized = true;

      debugPrint('Servicio de cámara inicializado correctamente con autofocus');
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
      // 🧪 TEST TEMPORAL: Test con imagen local de alta calidad ANTES de la captura real
      await _runLocalImageTest();
      
      debugPrint('🚀 Iniciando captura real...');
      
      // Capturar imagen
      final XFile image = await _controller!.takePicture();
      final imageFile = File(image.path);
      
      debugPrint('📷 Imagen capturada: ${image.path}');

      // Calcular bounds del overlay (240x336px centrado)
      final screenSize = _controller!.value.previewSize!;
      final overlayBounds = _calculateOverlayBounds(screenSize);
      
      debugPrint('📐 Screen size: ${screenSize.width}x${screenSize.height}');
              debugPrint('📐 Overlay bounds: ${overlayBounds.width}x${overlayBounds.height} at (${overlayBounds.left}, ${overlayBounds.top}) - Proporción 5:7');

      // Paso 1: Recortar imagen usando overlay bounds
      final cropResult = await _imageCropper.cropToOverlay(
        originalImage: imageFile,
        bounds: overlayBounds,
      );

      if (!cropResult.success) {
        debugPrint('❌ Error al recortar: ${cropResult.error}');
        return ScanResult.error(
          error: 'Error al recortar imagen: ${cropResult.error}',
          scanType: scanType,
        );
      }

      debugPrint('✂️ Imagen recortada exitosamente');

      // Paso 2: Extraer nombre usando OCR
      final ocrResult = await _ocrService.extractCardName(cropResult.croppedImageBytes);

      if (!ocrResult.success) {
        debugPrint('❌ Error en OCR: ${ocrResult.error}');
        return ScanResult.error(
          error: 'Error en OCR: ${ocrResult.error}',
          scanType: scanType,
        );
      }

      // 🎯 AQUÍ ESTÁ EL PRINT QUE QUERÍAS VER
      debugPrint('');
      debugPrint('🎯 ===== RESULTADO OCR =====');
      debugPrint('📝 NOMBRE DETECTADO: "${ocrResult.extractedText}"');
      debugPrint('🎯 CONFIDENCE: ${(ocrResult.confidence * 100).toStringAsFixed(1)}%');
      debugPrint('📋 CANDIDATOS: ${ocrResult.candidateNames}');
      debugPrint('🎯 ========================');
      debugPrint('');

      // Por ahora, retornar un mock simple para que no se rompa la UI
      // En el futuro esto se conectará con la API de Scryfall
      final mockCard = ScannedCard(
        name: ocrResult.extractedText, // Usar el nombre detectado
        type: 'Detectado por OCR',
        set: 'Real Scan',
        rarity: 'common',
        imageUrl: 'assets/images/prueba_carta.png',
        price: 0.00,
        priceFormatted: 'Procesando...',
        confidence: ocrResult.confidence,
      );

      return ScanResult.success(card: mockCard, scanType: scanType);
    } catch (e) {
      debugPrint('❌ Error general en captura: $e');
      return ScanResult.error(
        error: 'Error al capturar imagen: $e',
        scanType: scanType,
      );
    }
  }

  /// Calcula los bounds del overlay basándose en el tamaño de pantalla
  OverlayBounds _calculateOverlayBounds(Size screenSize) {
    // Dimensiones fijas del overlay (definidas en scan_camera_view.dart)
    const overlayWidth = 240.0;
    const overlayHeight = 336.0;
    
    // Calcular posición centrada
    final left = (screenSize.width - overlayWidth) / 2;
    final top = (screenSize.height - overlayHeight) / 2;
    
    return OverlayBounds(
      left: left,
      top: top,
      width: overlayWidth,
      height: overlayHeight,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
    );
  }

  /// Procesa una imagen para reconocer texto de cartas MTG
  Future<ScanResult> _processImage(String imagePath, ScanType scanType) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extraer información de la carta (simplificado por ahora)
      final cardInfo = _extractCardInfo(recognizedText.text);

      if (cardInfo == null) {
        return ScanResult.error(
          error: 'No se pudo reconocer la carta',
          scanType: scanType,
        );
      }

      return ScanResult.success(card: cardInfo, scanType: scanType);
    } catch (e) {
      debugPrint('Error al procesar imagen: $e');
      return ScanResult.error(
        error: 'Error al procesar imagen: $e',
        scanType: scanType,
      );
    }
  }

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
      
      // Procesar imagen para optimizar reconocimiento
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      // Aplicar mejoras básicas
      final enhanced = img.adjustColor(decodedImage, 
        contrast: 1.2, 
        brightness: 1.1
      );

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

  /// Test con imagen local de alta calidad  
  Future<void> testWithLocalImage(String imagePath) async {
    debugPrint('🧪 Iniciando test con imagen local desde CameraService...');
    await _ocrService.testWithLocalImage(imagePath);
  }

  /// Test interno con asset de imagen local
  Future<void> _runLocalImageTest() async {
    try {
      debugPrint('🧪 ===== EJECUTANDO TEST CON IMAGEN LOCAL =====');
      
      // Cargar asset y copiarlo a archivo temporal
      final assetPath = 'assets/images/prueba_carta.png';
      debugPrint('📁 Cargando asset: $assetPath');
      
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      debugPrint('📦 Asset cargado: ${bytes.length} bytes');
      
      // Crear archivo temporal
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/test_card_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(bytes);
      debugPrint('💾 Asset copiado a: ${tempFile.path}');
      
      // Ejecutar test
      await _ocrService.testWithLocalImage(tempFile.path);
      
      // Limpiar archivo temporal
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      debugPrint('🧪 ===== FIN TEST - CONTINUANDO CON CAPTURA REAL =====');
      
    } catch (e) {
      debugPrint('❌ Error en test con asset: $e');
    }
  }

  /// Libera recursos del servicio
  Future<void> dispose() async {
    await _textRecognizer.close();
    await _controller?.dispose();
    _isInitialized = false;
  }
}
