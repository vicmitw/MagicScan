import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magicscan/presentation/pages/scanner/widgets/manual_card_selection_popup.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/scanned_card.dart';
import '../../data/services/camera_service.dart';
import '../widgets/scanner/scan_result_popup.dart';
import '../widgets/scanner/scan_camera_view.dart';

/// Estado del controlador de escaneado
class ScanState {
  final bool isScanning;
  final ScanType? currentScanType;
  final List<ScannedCard> scannedCards;
  final int totalCardsScanned;
  final ScanResult? lastResult;
  final String? error;

  const ScanState({
    this.isScanning = false,
    this.currentScanType,
    this.scannedCards = const [],
    this.totalCardsScanned = 0,
    this.lastResult,
    this.error,
  });

  ScanState copyWith({
    bool? isScanning,
    ScanType? currentScanType,
    List<ScannedCard>? scannedCards,
    int? totalCardsScanned,
    ScanResult? lastResult,
    String? error,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      currentScanType: currentScanType ?? this.currentScanType,
      scannedCards: scannedCards ?? this.scannedCards,
      totalCardsScanned: totalCardsScanned ?? this.totalCardsScanned,
      lastResult: lastResult ?? this.lastResult,
      error: error ?? this.error,
    );
  }
}

/// Controlador para manejar la lógica de escaneado
class ScanController extends StateNotifier<ScanState> {
  final CameraService _cameraService;
  bool _simulateLowConfidence = true; // Flag para alternar la simulación

  ScanController(this._cameraService) : super(const ScanState());

  /// Inicia un escaneo según el tipo especificado
  Future<void> startScan(ScanType scanType, BuildContext context) async {
    try {
      state = state.copyWith(
        isScanning: true,
        currentScanType: scanType,
        error: null,
      );

      // Inicializar cámara si no está lista
      if (!_cameraService.isInitialized) {
        final success = await _cameraService.initialize();
        if (!success) {
          state = state.copyWith(
            isScanning: false,
            error: 'No se pudo inicializar la cámara',
          );
          return;
        }
      }

      // Configurar el servicio según el tipo de escaneo
      if (scanType == ScanType.freeScan) {
        _cameraService.startScanning();
      }

      // Navegar a la vista de cámara
      if (context.mounted) {
        await _navigateToCamera(context, scanType);
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: 'Error al iniciar escaneado: $e',
      );
    }
  }

  /// Detiene el escaneo actual
  void stopScan() {
    _cameraService.stopScanning();
    state = state.copyWith(isScanning: false, currentScanType: null);
  }

  /// Procesa un resultado de escaneo
  Future<void> _processScanResult(
    ScanResult result,
    BuildContext context,
  ) async {
    if (!result.hasCard) {
      // Mostrar error si no hay carta
      if (result.hasError) {
        state = state.copyWith(error: result.error);
      }
      return;
    }

    final card = result.card!;

    // Agregar carta a la lista
    final updatedCards = [...state.scannedCards, card];

    state = state.copyWith(
      scannedCards: updatedCards,
      totalCardsScanned: state.totalCardsScanned + 1,
      lastResult: result,
    );

    // Lógica de simulación para alternar entre popups
    if (_simulateLowConfidence) {
      // Escenario 1: Baja confianza -> mostramos el popup de selección manual
      // Creamos una lista de imágenes de prueba para el popup
      final mockImagePaths = [
        'assets/cartas_prueba_popup/image copy 5.png',
        'assets/cartas_prueba_popup/image copy 4.png',
        'assets/cartas_prueba_popup/image copy 3.png',
        'assets/cartas_prueba_popup/image copy 2.png',
        'assets/cartas_prueba_popup/image copy.png',
        'assets/cartas_prueba_popup/image.png',
      ];
      if (context.mounted) {
        await showManualCardSelectionDialog(context, mockImagePaths);
      }
    } else {
      // Escenario 2: Alta confianza -> mostramos el popup de éxito original
      if (context.mounted) {
        showScanResultPopup(
          context: context,
          card: card,
          scanType: result.scanType,
          onComplete: () => _onScanComplete(result.scanType, context),
          duration: const Duration(seconds: 4),
        );
      }
    }

    // Alternamos el flag para el próximo escaneo
    _simulateLowConfidence = !_simulateLowConfidence;
  }

  /// Maneja la finalización de un escaneo
  void _onScanComplete(ScanType scanType, BuildContext context) {
    switch (scanType) {
      case ScanType.quickScan:
        // Quick scan termina después de una carta
        _finishQuickScan(context);
        break;
      case ScanType.freeScan:
        // Free scan continúa hasta que el usuario lo detenga
        _continueFreeScan();
        break;
    }
  }

  /// Finaliza el Quick Scan
  void _finishQuickScan(BuildContext context) {
    stopScan();

    // Volver a la página principal
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Continúa el Free Scan
  void _continueFreeScan() {
    // El escaneo continúa, solo resetear el estado de procesamiento
    // El usuario puede seguir escaneando más cartas
  }

  /// Navega a la vista de cámara
  Future<void> _navigateToCamera(
    BuildContext context,
    ScanType scanType,
  ) async {
    final cameraView = _buildCameraView(scanType, context);

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => cameraView,
          fullscreenDialog: true,
        ),
      );
    }
  }

  /// Construye la vista de cámara
  Widget _buildCameraView(ScanType scanType, BuildContext context) {
    return ScanCameraView(
      scanType: scanType,
      onScanResult: (result) => _processScanResult(result, context),
      onClose: () {
        stopScan();
        Navigator.of(context).pop();
      },
    );
  }

  /// Limpia todas las cartas escaneadas
  void clearScannedCards() {
    state = state.copyWith(
      scannedCards: [],
      totalCardsScanned: 0,
      lastResult: null,
    );
  }

  /// Obtiene estadísticas del escaneo actual
  ScanStats get scanStats => ScanStats(
    totalCards: state.totalCardsScanned,
    totalValue: _calculateTotalValue(),
    averageConfidence: _calculateAverageConfidence(),
    scanType: state.currentScanType,
  );

  /// Calcula el valor total de las cartas escaneadas
  double _calculateTotalValue() {
    return state.scannedCards
        .where((card) => card.price != null)
        .fold(0.0, (sum, card) => sum + card.price!);
  }

  /// Calcula la confianza promedio de las cartas escaneadas
  double _calculateAverageConfidence() {
    if (state.scannedCards.isEmpty) return 0.0;

    final totalConfidence = state.scannedCards.fold(
      0.0,
      (sum, card) => sum + card.confidence,
    );

    return totalConfidence / state.scannedCards.length;
  }

  /// Libera recursos
  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}

/// Estadísticas del escaneo
class ScanStats {
  final int totalCards;
  final double totalValue;
  final double averageConfidence;
  final ScanType? scanType;

  const ScanStats({
    required this.totalCards,
    required this.totalValue,
    required this.averageConfidence,
    this.scanType,
  });

  String get formattedTotalValue => '\$${totalValue.toStringAsFixed(2)}';
  String get formattedAverageConfidence =>
      '${(averageConfidence * 100).toStringAsFixed(1)}%';
}

/// Proveedor del controlador de escaneado
final scanControllerProvider = StateNotifierProvider<ScanController, ScanState>(
  (ref) => ScanController(CameraService.instance),
);

/// Proveedor de estadísticas de escaneo
final scanStatsProvider = Provider<ScanStats>((ref) {
  final controller = ref.watch(scanControllerProvider.notifier);
  return controller.scanStats;
});

/// Extensión para facilitar el uso del controlador
extension ScanControllerExtension on WidgetRef {
  ScanController get scanController => read(scanControllerProvider.notifier);
  ScanState get scanState => watch(scanControllerProvider);
  ScanStats get scanStats => watch(scanStatsProvider);
}
