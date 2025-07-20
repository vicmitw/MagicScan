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
  final String? manaCost;
  final String? description;

  const ScannedCard({
    required this.name,
    this.type,
    this.set,
    this.rarity,
    this.imageUrl,
    this.price,
    this.priceFormatted,
    this.confidence = 0.0,

    this.manaCost,
    this.description,
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
      manaCost: json['mana_cost'],
      description: json['oracle_text'],
    );
  }

  /// Crea una instancia de prueba para desarrollo
  factory ScannedCard.mock() {
    return const ScannedCard(
      name: 'Obeka, Brute Chronologist',
      type: 'Legendary Creature — Ogre Wizard',
      set: 'Commander Legends',
      rarity: 'rare',
      imageUrl: 'assets/images/prueba_carta.png',
      price: 0.68,
      priceFormatted: '\$0.68',
      confidence: 0.98,
      manaCost: '{1}{U}{B}{R}',
      description: 'Tap: The player whose turn it is may end the turn. (Exile all spells and abilities from the stack. The player whose turn it is discards down to their maximum hand size. Damage wears off, and "this turn" and "until end of turn" effects end.)',
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
      'mana_cost': manaCost,
      'description': description,
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
      manaCost: json['mana_cost'],
      description: json['description'],
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

        manaCost,
        description,
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
    String? manaCost,
    String? description,
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
      manaCost: manaCost ?? this.manaCost,
      description: description ?? this.description,
    );
  }

  /// Devuelve true si la URL de la imagen es un asset local
  bool get isLocal => imageUrl?.startsWith('assets/') ?? false;

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