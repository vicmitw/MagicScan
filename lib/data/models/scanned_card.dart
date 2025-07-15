import 'package:equatable/equatable.dart';

/// Modelo que representa una carta detectada durante el escaneo
class ScannedCard extends Equatable {
  final String name;
  final String? type;
  final String? set;
  final String? rarity;
  final String? imageUrl;
  final double? price;
  final String? priceFormatted;
  final double confidence; // Confianza en la detección (0.0 - 1.0)

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

  /// Crea una instancia desde una respuesta de API
  factory ScannedCard.fromApi(Map<String, dynamic> json) {
    return ScannedCard(
      name: json['name'] ?? '',
      type: json['type_line'],
      set: json['set_name'],
      rarity: json['rarity'],
      imageUrl: json['image_uris']?['normal'],
      price: _parsePrice(json['prices']?['usd']),
      priceFormatted: _formatPrice(json['prices']?['usd']),
      confidence: json['confidence']?.toDouble() ?? 0.8,
    );
  }

  /// Crea una instancia de prueba para desarrollo
  factory ScannedCard.mock() {
    return const ScannedCard(
      name: 'Lightning Bolt',
      type: 'Instant',
      set: 'Magic 2011',
      rarity: 'common',
      imageUrl: 'assets/images/prueba_carta.png',
      price: 0.25,
      priceFormatted: '\$0.25',
      confidence: 0.95,
    );
  }

  /// Convierte a JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'set': set,
      'rarity': rarity,
      'image_url': imageUrl,
      'price': price,
      'price_formatted': priceFormatted,
      'confidence': confidence,
    };
  }

  /// Crea una instancia desde JSON almacenado
  factory ScannedCard.fromJson(Map<String, dynamic> json) {
    return ScannedCard(
      name: json['name'] ?? '',
      type: json['type'],
      set: json['set'],
      rarity: json['rarity'],
      imageUrl: json['image_url'],
      price: json['price']?.toDouble(),
      priceFormatted: json['price_formatted'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
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

  /// Crea una copia con parámetros modificados
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

  /// Parsea el precio desde string
  static double? _parsePrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return null;
    return double.tryParse(priceString);
  }

  /// Formatea el precio para mostrar
  static String? _formatPrice(String? priceString) {
    final price = _parsePrice(priceString);
    if (price == null) return null;
    return '\$${price.toStringAsFixed(2)}';
  }
}
