import '../entities/scan_result.dart';
import '../repositories/camera_repository.dart';

/// Caso de uso para escanear una carta
/// Siguiendo el Single Responsibility Principle (SRP)
class ScanCardUseCase {
  final CameraRepository _cameraRepository;

  const ScanCardUseCase(this._cameraRepository);

  /// Ejecuta el escaneo de una carta
  Future<ScanResult> execute(ScanType scanType) async {
    try {
      // Verificar que la cámara esté inicializada
      if (!_cameraRepository.isInitialized) {
        final initialized = await _cameraRepository.initialize();
        if (!initialized) {
          return ScanResult.error(
            error: 'No se pudo inicializar la cámara',
            scanType: scanType,
          );
        }
      }

      // Capturar y procesar la imagen
      final result = await _cameraRepository.captureAndProcess(scanType);
      return result;
    } catch (e) {
      return ScanResult.error(
        error: 'Error durante el escaneo: $e',
        scanType: scanType,
      );
    }
  }
} 