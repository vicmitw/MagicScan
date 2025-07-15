import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa una carta escaneada
/// Siguiendo el Single Responsibility Principle (SRP)
class ScannedCard extends Equatable {
  final String name;
  final String? type;
  final String? set;
  final String? rarity;
  final String? imageUrl;
  final double? price;
  final String? priceFormatted;
  final double confidence;

  const ScannedCard({
    required this.name,
    this.type,
    this.set,
    this.rarity,
    this.imageUrl,
    this.price,
    this.priceFormatted,
    this.confidence = 0.0,
  });

  /// Verifica si la carta tiene una imagen válida
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Verifica si la carta tiene precio válido
  bool get hasPrice => price != null && price! > 0;

  /// Verifica si la confianza del escaneo es alta
  bool get isHighConfidence => confidence >= 0.8;

  /// Verifica si la confianza del escaneo es baja
  bool get isLowConfidence => confidence < 0.6;

  /// Crea una copia de la carta con campos actualizados
  ScannedCard copyWith({
    String? name,
    String? type,
    String? set,
    String? rarity,
    String? imageUrl,
    double? price,
    String? priceFormatted,
    double? confidence,
  }) {
    return ScannedCard(
      name: name ?? this.name,
      type: type ?? this.type,
      set: set ?? this.set,
      rarity: rarity ?? this.rarity,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  List<Object?> get props => [
        name,
        type,
        set,
        rarity,
        imageUrl,
        price,
        priceFormatted,
        confidence,
      ];

  @override
  String toString() {
    return 'ScannedCard(name: $name, price: $priceFormatted, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
} 