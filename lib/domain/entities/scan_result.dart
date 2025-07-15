import 'package:equatable/equatable.dart';
import 'scanned_card.dart';

/// Entidad que representa el resultado de un escaneo
/// Siguiendo el Single Responsibility Principle (SRP)
class ScanResult extends Equatable {
  final bool isSuccess;
  final ScannedCard? card;
  final String? error;
  final ScanType scanType;
  final DateTime timestamp;

  const ScanResult._({
    required this.isSuccess,
    this.card,
    this.error,
    required this.scanType,
    required this.timestamp,
  });

  /// Constructor para resultado exitoso
  factory ScanResult.success({
    required ScannedCard card,
    required ScanType scanType,
  }) {
    return ScanResult._(
      isSuccess: true,
      card: card,
      scanType: scanType,
      timestamp: DateTime.now(),
    );
  }

  /// Constructor para resultado con error
  factory ScanResult.error({
    required String error,
    required ScanType scanType,
  }) {
    return ScanResult._(
      isSuccess: false,
      error: error,
      scanType: scanType,
      timestamp: DateTime.now(),
    );
  }

  /// Verifica si el resultado tiene una carta válida
  bool get hasCard => isSuccess && card != null;

  /// Verifica si el resultado tiene un error
  bool get hasError => !isSuccess && error != null;

  @override
  List<Object?> get props => [
        isSuccess,
        card,
        error,
        scanType,
        timestamp,
      ];

  @override
  String toString() {
    if (hasCard) {
      return 'ScanResult.success(card: ${card!.name})';
    } else {
      return 'ScanResult.error(error: $error)';
    }
  }
}

/// Enumeración para tipos de escaneo
enum ScanType {
  quickScan('Quick Scan'),
  freeScan('Free Scan');

  const ScanType(this.displayName);
  final String displayName;
} 