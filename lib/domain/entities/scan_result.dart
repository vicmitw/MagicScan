import 'package:equatable/equatable.dart';
import 'scanned_card.dart';

/// Tipos de escaneo disponibles
enum ScanType {
  quickScan, // Escaneo rápido individual
  freeScan, // Escaneo continuo de mazos
}

/// Estados del proceso de escaneo
enum ScanStatus {
  idle, // No hay escaneo activo
  scanning, // Escaneando activamente
  processing, // Procesando imagen detectada
  success, // Carta detectada con éxito
  error, // Error en el escaneo
}

/// Resultado del proceso de escaneo
class ScanResult extends Equatable {
  final ScanStatus status;
  final ScannedCard? card;
  final String? error;
  final ScanType scanType;
  final DateTime timestamp;
  final int? totalCardsScanned; // Para free scan

  const ScanResult({
    required this.status,
    this.card,
    this.error,
    required this.scanType,
    required this.timestamp,
    this.totalCardsScanned,
  });

  /// Crea un resultado exitoso
  factory ScanResult.success({
    required ScannedCard card,
    required ScanType scanType,
    int? totalCardsScanned,
  }) {
    return ScanResult(
      status: ScanStatus.success,
      card: card,
      scanType: scanType,
      timestamp: DateTime.now(),
      totalCardsScanned: totalCardsScanned,
    );
  }

  /// Crea un resultado de error
  factory ScanResult.error({
    required String error,
    required ScanType scanType,
  }) {
    return ScanResult(
      status: ScanStatus.error,
      error: error,
      scanType: scanType,
      timestamp: DateTime.now(),
    );
  }

  /// Crea un resultado de escaneo en progreso
  factory ScanResult.scanning({required ScanType scanType}) {
    return ScanResult(
      status: ScanStatus.scanning,
      scanType: scanType,
      timestamp: DateTime.now(),
    );
  }

  /// Crea un resultado de procesamiento
  factory ScanResult.processing({required ScanType scanType}) {
    return ScanResult(
      status: ScanStatus.processing,
      scanType: scanType,
      timestamp: DateTime.now(),
    );
  }

  /// Crea un resultado idle
  factory ScanResult.idle({required ScanType scanType}) {
    return ScanResult(
      status: ScanStatus.idle,
      scanType: scanType,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    status,
    card,
    error,
    scanType,
    timestamp,
    totalCardsScanned,
  ];

  /// Crea una copia con parámetros modificados
  ScanResult copyWith({
    ScanStatus? status,
    ScannedCard? card,
    String? error,
    ScanType? scanType,
    DateTime? timestamp,
    int? totalCardsScanned,
  }) {
    return ScanResult(
      status: status ?? this.status,
      card: card ?? this.card,
      error: error ?? this.error,
      scanType: scanType ?? this.scanType,
      timestamp: timestamp ?? this.timestamp,
      totalCardsScanned: totalCardsScanned ?? this.totalCardsScanned,
    );
  }

  /// Indica si el escaneo está activo
  bool get isActive =>
      status == ScanStatus.scanning || status == ScanStatus.processing;

  /// Indica si hay una carta detectada
  bool get hasCard => card != null;

  /// Indica si hay un error
  bool get hasError => error != null;

  /// Convierte a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'card': card?.toJson(),
      'error': error,
      'scan_type': scanType.name,
      'timestamp': timestamp.toIso8601String(),
      'total_cards_scanned': totalCardsScanned,
    };
  }

  /// Crea una instancia desde JSON
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      status: ScanStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ScanStatus.idle,
      ),
      card: json['card'] != null ? ScannedCard.fromJson(json['card']) : null,
      error: json['error'],
      scanType: ScanType.values.firstWhere(
        (t) => t.name == json['scan_type'],
        orElse: () => ScanType.quickScan,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      totalCardsScanned: json['total_cards_scanned'],
    );
  }
}

/// Extensión para obtener texto descriptivo del tipo de escaneo
extension ScanTypeExtension on ScanType {
  String get displayName {
    switch (this) {
      case ScanType.quickScan:
        return 'Quick Scan';
      case ScanType.freeScan:
        return 'Free Scan';
    }
  }

  String get description {
    switch (this) {
      case ScanType.quickScan:
        return 'Escaneo rápido individual';
      case ScanType.freeScan:
        return 'Escaneo continuo de mazos';
    }
  }
}

/// Extensión para obtener texto descriptivo del estado
extension ScanStatusExtension on ScanStatus {
  String get displayName {
    switch (this) {
      case ScanStatus.idle:
        return 'Listo';
      case ScanStatus.scanning:
        return 'Escaneando...';
      case ScanStatus.processing:
        return 'Procesando...';
      case ScanStatus.success:
        return 'Completado';
      case ScanStatus.error:
        return 'Error';
    }
  }
} 