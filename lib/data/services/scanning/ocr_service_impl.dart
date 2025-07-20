import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../../domain/services/scanning/core/ocr_service.dart';
import '../../../domain/services/scanning/core/image_cropper_service.dart';
import 'image_cropper_service_impl.dart';

/// Implementación del servicio OCR usando Google ML Kit
/// Approach universal que funciona con cualquier tipo de carta
class OCRServiceImpl implements OCRService {
  // Configurar TextRecognizer para mejor detección de texto en inglés (cartas MTG)
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin
  );
  
  // Servicio de recorte para test con imagen local
  final ImageCropperService _imageCropper = ImageCropperServiceImpl();

  @override
  Future<OCRResult> extractCardName(
    Uint8List croppedImage, {
    OCRConfig config = OCRConfig.mtgOptimized,
  }) async {
    try {
      // Paso 1: Recortar región superior (20% top)
      final nameRegionImage = await _cropNameRegion(croppedImage);
      
      // Paso 2: Mejorar imagen para OCR si es necesario
      final enhancedImage = config.enhanceContrast 
          ? await _enhanceForOCR(nameRegionImage)
          : nameRegionImage;

      // Paso 3: Crear archivo temporal para JPEG y ejecutar OCR
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ocr_temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      try {
        await tempFile.writeAsBytes(enhancedImage);
        debugPrint('💾 Archivo temporal creado: ${tempFile.path} (${enhancedImage.length} bytes)');
        
        // Verificar que el archivo se puede leer
        final fileExists = await tempFile.exists();
        final fileSize = await tempFile.length();
        debugPrint('📁 Archivo existe: $fileExists, tamaño: $fileSize bytes');
        
        final inputImage = InputImage.fromFilePath(tempFile.path);
        var recognizedText = await _textRecognizer.processImage(inputImage);
        
        // Si no se detecta texto, intentar con configuración alternativa
        if (recognizedText.blocks.isEmpty) {
          debugPrint('🔄 Intentando OCR con configuración alternativa...');
          final altRecognizer = TextRecognizer();
          try {
            recognizedText = await altRecognizer.processImage(inputImage);
            await altRecognizer.close();
            debugPrint('🔄 Resultado con configuración alternativa: ${recognizedText.blocks.length} bloques');
          } catch (e) {
            debugPrint('❌ Error con configuración alternativa: $e');
          }
          
          // Si aún no hay texto, probar ML Kit con imagen sintética
          if (recognizedText.blocks.isEmpty) {
            await _testMLKitWithSyntheticImage();
          }
        }

        // Debug detallado del texto reconocido
        debugPrint('📊 OCR Text blocks: ${recognizedText.blocks.length}');
        debugPrint('📊 OCR Full text length: ${recognizedText.text.length}');
        
        if (recognizedText.blocks.isEmpty) {
          debugPrint('⚠️ No se detectaron bloques de texto - posibles causas:');
          debugPrint('   • Imagen muy pequeña o borrosa');
          debugPrint('   • Contraste insuficiente');
          debugPrint('   • Texto no es legible para ML Kit');
          debugPrint('   • Formato de imagen incorrecto');
        } else {
          for (int i = 0; i < recognizedText.blocks.length; i++) {
            final block = recognizedText.blocks[i];
            debugPrint('📝 Block $i: "${block.text}"');
            debugPrint('📐 Block $i rect: ${block.boundingBox}');
            debugPrint('📏 Block $i size: ${block.boundingBox.width}x${block.boundingBox.height}');
          }
        }

        // Paso 4: Analizar texto y extraer nombre
        final result = _analyzeTextForCardName(recognizedText);
        
        debugPrint('🔍 OCR Raw text: "${recognizedText.text}"');
        debugPrint('📝 Extracted name: "${result.extractedText}"');
        debugPrint('🎯 Confidence: ${result.confidence}');

        return result;
      } finally {
        // Limpiar archivo temporal
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e) {
      debugPrint('❌ OCR Error: $e');
      return OCRResult.error('Error en OCR: $e');
    }
  }

  @override
  Future<OCRResult> extractAllText(
    Uint8List croppedImage, {
    OCRConfig config = OCRConfig.mtgOptimized,
  }) async {
    try {
      // Crear archivo temporal para JPEG
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ocr_full_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      try {
        await tempFile.writeAsBytes(croppedImage);
        
        final inputImage = InputImage.fromFilePath(tempFile.path);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        
        return OCRResult.success(
          text: recognizedText.text,
          confidence: 0.8, // Confidence base para texto completo
        );
      } finally {
        // Limpiar archivo temporal
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e) {
      return OCRResult.error('Error en OCR completo: $e');
    }
  }

  @override
  String normalizeCardName(String rawText) {
    // Limpiar texto común de OCR
    String normalized = rawText
        .trim()
        .replaceAll(RegExp(r'[^\w\s\-\x27,]'), '') // Mantener letras, números, espacios, guiones, apostrofes, comas
        .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espacios múltiples
        .toLowerCase()
        .trim();

    // Capitalizar primera letra de cada palabra
    return normalized
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1)
            : word)
        .join(' ');
  }

  @override
  bool isValidCardName(String text) {
    if (text.length < 2 || text.length > 50) return false;
    
    // Filtrar texto que obviamente no es nombre de carta
    final invalidPatterns = [
      RegExp(r'^\d+$'), // Solo números
      RegExp(r'^[+\-]?\d+/[+\-]?\d+$'), // Power/Toughness como "3/3"
      RegExp(r'^[WUBRG]+$'), // Solo símbolos de mana
      RegExp(r'^(Token|Land|Creature|Instant|Sorcery|Artifact|Enchantment|Planeswalker)$', caseSensitive: false),
    ];

    return !invalidPatterns.any((pattern) => pattern.hasMatch(text.trim()));
  }

  /// Recorta la región superior donde siempre aparece el nombre (20% top)
  Future<Uint8List> _cropNameRegion(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('No se pudo decodificar imagen');

    debugPrint('🖼️ Imagen original: ${image.width}x${image.height}');
    
    final cropHeight = (image.height * 0.25).round(); // 25% superior (más área para nombres largos)
    debugPrint('✂️ Recortando región del nombre: ${image.width}x$cropHeight (25% superior)');
    
    var nameRegion = img.copyCrop(
      image,
      x: 0,
      y: 0,
      width: image.width,
      height: cropHeight,
    );

    // Si la imagen es muy pequeña, redimensionar para mejor OCR
    if (nameRegion.width < 200 || nameRegion.height < 50) {
      final targetWidth = nameRegion.width < 200 ? 400 : nameRegion.width * 2;
      final targetHeight = (targetWidth * nameRegion.height / nameRegion.width).round();
      
      nameRegion = img.copyResize(
        nameRegion, 
        width: targetWidth, 
        height: targetHeight,
        interpolation: img.Interpolation.cubic
      );
      
      debugPrint('🔍 Imagen redimensionada para OCR: ${nameRegion.width}x${nameRegion.height}');
    }

    final result = Uint8List.fromList(img.encodeJpg(nameRegion, quality: 98));
    debugPrint('✅ Región del nombre creada: ${result.length} bytes');
    
    // Guardar imagen debug para inspección manual
    await _saveDebugImage(result, 'cropped_region');
    
    return result;
  }

  /// Mejora la imagen para mejor OCR
  Future<Uint8List> _enhanceForOCR(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    var enhanced = image;
    
    // Aumentar contraste agresivamente para texto
    enhanced = img.contrast(enhanced, contrast: 1.5);
    
    // Ajustar brillo
    enhanced = img.adjustColor(enhanced, brightness: 1.15);
    
    // Aumentar nitidez para texto más claro (filtro de sharpen)
    enhanced = img.convolution(enhanced, 
      filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
      ],
      div: 1,
    );

    debugPrint('✨ Imagen mejorada para OCR');
    
    final result = Uint8List.fromList(img.encodeJpg(enhanced, quality: 98));
    
    // Guardar imagen debug para inspección manual
    await _saveDebugImage(result, 'enhanced_ocr');
    
    return result;
  }

  /// Analiza el texto reconocido para extraer el nombre de la carta
  OCRResult _analyzeTextForCardName(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) {
      return OCRResult.error('No se detectó texto');
    }

    List<String> candidates = [];
    double bestConfidence = 0.0;
    String bestCandidate = '';

    // Analizar cada bloque de texto
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        
        if (isValidCardName(text)) {
          candidates.add(text);
          
          // Calcular confidence basado en posición y características
          double confidence = _calculateNameConfidence(line, recognizedText);
          
          if (confidence > bestConfidence) {
            bestConfidence = confidence;
            bestCandidate = text;
          }
        }
      }
    }

    if (bestCandidate.isEmpty) {
      return OCRResult.error('No se encontró nombre válido');
    }

    final normalizedName = normalizeCardName(bestCandidate);
    
    return OCRResult.success(
      text: normalizedName,
      confidence: bestConfidence,
      candidates: candidates.map(normalizeCardName).toList(),
    );
  }

  /// Calcula confidence del nombre basado en posición y características
  double _calculateNameConfidence(TextLine line, RecognizedText fullText) {
    double confidence = 0.5; // Base confidence

    // Bonus por estar en parte superior
    final relativeY = line.boundingBox.top / 
        (fullText.blocks.isNotEmpty ? fullText.blocks.first.boundingBox.height : 100);
    
    if (relativeY < 0.3) confidence += 0.3; // Muy arriba = bonus

    // Bonus por tamaño de texto (líneas más grandes = más probable nombre)
    final lineHeight = line.boundingBox.height;
    if (lineHeight > 30) confidence += 0.2;

    // Bonus por estar centrado horizontalmente (para tokens)
    final centerX = line.boundingBox.center.dx;
    final imageCenterX = line.boundingBox.width / 2;
    final centerDistance = (centerX - imageCenterX).abs();
    
    if (centerDistance < 50) confidence += 0.1; // Centrado = bonus

    return confidence.clamp(0.0, 1.0);
  }

  /// Prueba ML Kit con imagen sintética para verificar que funciona
  Future<void> _testMLKitWithSyntheticImage() async {
    try {
      debugPrint('🧪 Iniciando test de ML Kit con carta MTG sintética...');
      
      // Crear imagen de carta MTG sintética con texto claro
      final testImage = img.fill(
        img.Image(width: 400, height: 120),
        color: img.ColorRgb8(245, 240, 230), // Fondo beige típico de cartas MTG
      );
      
      // Simular el nombre de una carta - "Lightning Bolt" con píxeles grandes
      // L
      _drawLetterPixels(testImage, 30, 30, [
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,0,0,0,0],
        [1,1,1,1,1]
      ]);
      
      // Crear texto más legible usando rectángulos simples
      final textRegions = [
        {'x': 50, 'y': 35, 'w': 200, 'h': 25}, // Región principal de texto
        {'x': 60, 'y': 45, 'w': 180, 'h': 8},  // Línea de texto
      ];
      
      for (final region in textRegions) {
        for (int x = region['x']! as int; x < (region['x']! as int) + (region['w']! as int); x += 3) {
          for (int y = region['y']! as int; y < (region['y']! as int) + (region['h']! as int); y += 2) {
            if ((x + y) % 4 == 0) { // Patrón para simular texto
              testImage.setPixel(x, y, img.ColorRgb8(20, 20, 20)); // Negro
            }
          }
        }
      }
      
      final testBytes = Uint8List.fromList(img.encodeJpg(testImage, quality: 95));
      
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/synthetic_mtg_test_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await testFile.writeAsBytes(testBytes);
      
      debugPrint('🧪 Imagen sintética guardada: ${testFile.path}');
      
      final inputImage = InputImage.fromFilePath(testFile.path);
      final result = await _textRecognizer.processImage(inputImage);
      
      debugPrint('🧪 Test Sintético - Bloques detectados: ${result.blocks.length}');
      debugPrint('🧪 Test Sintético - Texto completo: "${result.text}"');
      
      for (int i = 0; i < result.blocks.length; i++) {
        debugPrint('🧪 Block $i: "${result.blocks[i].text}"');
      }
      
      // Limpiar archivo de test
      if (await testFile.exists()) {
        await testFile.delete();
      }
      
    } catch (e) {
      debugPrint('❌ Error en test sintético: $e');
    }
  }

  /// Dibuja píxeles para formar letras (helper para test)
  void _drawLetterPixels(img.Image image, int startX, int startY, List<List<int>> pattern) {
    for (int row = 0; row < pattern.length; row++) {
      for (int col = 0; col < pattern[row].length; col++) {
        if (pattern[row][col] == 1) {
          for (int dx = 0; dx < 4; dx++) {
            for (int dy = 0; dy < 4; dy++) {
              final x = startX + (col * 4) + dx;
              final y = startY + (row * 4) + dy;
              if (x < image.width && y < image.height) {
                image.setPixel(x, y, img.ColorRgb8(0, 0, 0));
              }
            }
          }
        }
      }
    }
  }

  /// Guarda imagen para debugging manual
  Future<void> _saveDebugImage(Uint8List imageBytes, String prefix) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final debugFile = File('${tempDir.path}/debug_${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await debugFile.writeAsBytes(imageBytes);
      debugPrint('🔍 Imagen debug guardada: ${debugFile.path}');
    } catch (e) {
      debugPrint('❌ Error guardando imagen debug: $e');
    }
  }

  /// Test con imagen local de alta calidad
  Future<void> testWithLocalImage(String imagePath) async {
    try {
      debugPrint('🧪 ===== TEST CON IMAGEN LOCAL =====');
      debugPrint('📁 Procesando: $imagePath');
      
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('❌ Archivo no encontrado: $imagePath');
        return;
      }
      
      final imageBytes = await imageFile.readAsBytes();
      debugPrint('📦 Tamaño archivo original: ${imageBytes.length} bytes');
      
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('❌ No se pudo decodificar imagen');
        return;
      }
      
      debugPrint('🖼️ Imagen local: ${image.width}x${image.height}');
      
      // 🧪 TEST 1: Asumir que YA ES UNA CARTA RECORTADA (directo a OCR)
      debugPrint('');
      debugPrint('🧪 ===== TEST 1: CARTA YA RECORTADA =====');
      await _testAsPreCroppedCard(imageBytes);
      
      // 🧪 TEST 2: Pipeline completo con simulación de overlay
      debugPrint('');
      debugPrint('🧪 ===== TEST 2: PIPELINE COMPLETO =====');
      await _testWithFullPipeline(imageBytes, image);
      
      debugPrint('🎯 ===== FIN TESTS LOCALES =====');
      
    } catch (e) {
      debugPrint('❌ Error en test con imagen local: $e');
    }
  }

  /// Test asumiendo que la imagen ya es una carta recortada
  Future<void> _testAsPreCroppedCard(Uint8List imageBytes) async {
    try {
      debugPrint('📝 Asumiendo que imagen YA es carta recortada...');
      
      // 🧪 TEST 1A: CON filtros de mejora (actual)
      debugPrint('🧪 --- Test 1A: CON filtros ---');
      final ocrResult1 = await extractCardName(
        imageBytes,
        config: OCRConfig.mtgOptimized,
      );
      
      debugPrint('🎯 RESULTADO TEST 1A (CON FILTROS):');
      debugPrint('📝 NOMBRE DETECTADO: "${ocrResult1.extractedText}"');
      debugPrint('🎯 CONFIDENCE: ${(ocrResult1.confidence * 100).toStringAsFixed(1)}%');
      debugPrint('✅ ÉXITO: ${ocrResult1.success}');
      
      // 🧪 TEST 1B: SIN filtros de mejora (test crítico)
      debugPrint('');
      debugPrint('🧪 --- Test 1B: SIN filtros ---');
      final ocrResult2 = await _testOCRWithoutEnhancement(imageBytes);
      
      debugPrint('🎯 RESULTADO TEST 1B (SIN FILTROS):');
      debugPrint('📝 NOMBRE DETECTADO: "${ocrResult2.extractedText}"');
      debugPrint('🎯 CONFIDENCE: ${(ocrResult2.confidence * 100).toStringAsFixed(1)}%');
      debugPrint('✅ ÉXITO: ${ocrResult2.success}');
      
    } catch (e) {
      debugPrint('❌ Error en test carta pre-recortada: $e');
    }
  }

  /// Test crítico: OCR sin filtros de mejora
  Future<OCRResult> _testOCRWithoutEnhancement(Uint8List imageBytes) async {
    try {
      // Extraer región del nombre SIN aplicar filtros de mejora
      final nameRegionBytes = await _cropNameRegion(imageBytes);
      
      // Crear archivo temporal para usar con InputImage.fromFilePath
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/test_no_filters_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(nameRegionBytes);
      
      // Aplicar OCR directamente sin filtros
      debugPrint('🔍 Aplicando OCR SIN filtros de mejora...');
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      debugPrint('📊 OCR sin filtros - Text blocks: ${recognizedText.blocks.length}');
      debugPrint('📊 OCR sin filtros - Full text length: ${recognizedText.text.length}');
      
      // Limpiar archivo temporal
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      return _analyzeTextForCardName(recognizedText);
    } catch (e) {
      return OCRResult.error('Error en test sin filtros: $e');
    }
  }

  /// Test con pipeline completo (simular cámara)
  Future<void> _testWithFullPipeline(Uint8List imageBytes, img.Image image) async {
    try {
      debugPrint('📝 Simulando pipeline completo de cámara...');
      
      // Crear bounds simulados (tomar el centro de la imagen, proporción 5:7)
      final overlayWidth = (image.width * 0.6).round(); // 60% del ancho
      final overlayHeight = (overlayWidth * 1.4).round(); // Proporción 5:7
      final left = (image.width - overlayWidth) / 2;
      final top = (image.height - overlayHeight) / 2;
      
      final bounds = OverlayBounds(
        left: left,
        top: top,
        width: overlayWidth.toDouble(),
        height: overlayHeight.toDouble(),
        screenWidth: image.width.toDouble(),
        screenHeight: image.height.toDouble(),
      );
      
      debugPrint('📐 Bounds simulados: ${bounds.width}x${bounds.height} at (${bounds.left}, ${bounds.top})');
      
      // Procesar con nuestro pipeline completo
      final cropResult = await _imageCropper.cropFromBytes(
        imageBytes: imageBytes,
        bounds: bounds,
      );
      
      if (!cropResult.success) {
        debugPrint('❌ Error al recortar imagen en pipeline: ${cropResult.error}');
        return;
      }
      
      // Ejecutar OCR
      final ocrResult = await extractCardName(
        cropResult.croppedImageBytes,
        config: OCRConfig.mtgOptimized,
      );
      
      debugPrint('🎯 RESULTADO TEST 2 (PIPELINE COMPLETO):');
      debugPrint('📝 NOMBRE DETECTADO: "${ocrResult.extractedText}"');
      debugPrint('🎯 CONFIDENCE: ${(ocrResult.confidence * 100).toStringAsFixed(1)}%');
      debugPrint('✅ ÉXITO: ${ocrResult.success}');
      
    } catch (e) {
      debugPrint('❌ Error en test pipeline completo: $e');
    }
  }

  /// Limpia recursos
  void dispose() {
    _textRecognizer.close();
  }
} 