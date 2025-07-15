import 'package:flutter/foundation.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/use_cases/scan_card_use_case.dart';
import '../../domain/repositories/camera_repository.dart';

/// Estado del controlador de cámara
/// Siguiendo el Single Responsibility Principle (SRP)
@immutable
class CameraState {
  final bool isInitialized;
  final bool isScanning;
  final FlashMode flashMode;
  final ScanResult? lastResult;
  final String? error;

  const CameraState({
    this.isInitialized = false,
    this.isScanning = false,
    this.flashMode = FlashMode.off,
    this.lastResult,
    this.error,
  });

  CameraState copyWith({
    bool? isInitialized,
    bool? isScanning,
    FlashMode? flashMode,
    ScanResult? lastResult,
    String? error,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isScanning: isScanning ?? this.isScanning,
      flashMode: flashMode ?? this.flashMode,
      lastResult: lastResult ?? this.lastResult,
      error: error,
    );
  }
}

/// Controlador para operaciones de cámara
/// Siguiendo el Single Responsibility Principle (SRP)
class CameraController extends ValueNotifier<CameraState> {
  final ScanCardUseCase _scanCardUseCase;
  final CameraRepository _cameraRepository;

  CameraController({
    required ScanCardUseCase scanCardUseCase,
    required CameraRepository cameraRepository,
  })  : _scanCardUseCase = scanCardUseCase,
        _cameraRepository = cameraRepository,
        super(const CameraState());

  /// Inicializa la cámara
  Future<void> initialize() async {
    try {
      value = value.copyWith(error: null);
      
      final success = await _cameraRepository.initialize();
      
      value = value.copyWith(
        isInitialized: success,
        error: success ? null : 'Error al inicializar la cámara',
      );
    } catch (e) {
      value = value.copyWith(
        isInitialized: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  /// Ejecuta el escaneo de una carta
  Future<void> scanCard(ScanType scanType) async {
    if (!value.isInitialized || value.isScanning) return;

    value = value.copyWith(isScanning: true, error: null);

    try {
      final result = await _scanCardUseCase.execute(scanType);
      
      value = value.copyWith(
        isScanning: false,
        lastResult: result,
        error: result.hasError ? result.error : null,
      );
    } catch (e) {
      value = value.copyWith(
        isScanning: false,
        error: 'Error durante el escaneo: $e',
      );
    }
  }

  /// Cambia el modo flash
  Future<void> toggleFlash() async {
    if (!value.isInitialized) return;

    final newFlashMode = value.flashMode == FlashMode.off 
        ? FlashMode.torch 
        : FlashMode.off;

    try {
      await _cameraRepository.setFlashMode(newFlashMode);
      value = value.copyWith(flashMode: newFlashMode);
    } catch (e) {
      value = value.copyWith(error: 'Error al cambiar flash: $e');
    }
  }

  /// Cambia entre cámaras
  Future<void> switchCamera() async {
    if (!value.isInitialized) return;

    try {
      final success = await _cameraRepository.switchCamera();
      if (!success) {
        value = value.copyWith(error: 'No se pudo cambiar de cámara');
      }
    } catch (e) {
      value = value.copyWith(error: 'Error al cambiar cámara: $e');
    }
  }

  /// Limpia el último resultado
  void clearLastResult() {
    value = value.copyWith(lastResult: null, error: null);
  }

  @override
  void dispose() {
    _cameraRepository.dispose();
    super.dispose();
  }
} 