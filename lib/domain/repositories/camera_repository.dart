import 'dart:typed_data';
import '../entities/scan_result.dart';

/// Interfaz para el repositorio de la cámara
/// Siguiendo el Dependency Inversion Principle (DIP)
abstract class CameraRepository {
  /// Inicializa el sistema de cámara
  Future<bool> initialize();

  /// Verifica si la cámara está inicializada
  bool get isInitialized;

  /// Captura y procesa una imagen para detectar cartas
  Future<ScanResult> captureAndProcess(ScanType scanType);

  /// Cambia entre cámaras frontal y trasera
  Future<bool> switchCamera();

  /// Configura el modo flash
  Future<void> setFlashMode(FlashMode flashMode);

  /// Obtiene una vista previa optimizada
  Future<Uint8List?> getOptimizedPreview();

  /// Libera recursos de la cámara
  Future<void> dispose();
}

/// Enumeración para modos de flash
enum FlashMode {
  off,
  torch,
  auto,
} 