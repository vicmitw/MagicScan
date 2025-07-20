import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import './card_rarity_tag.dart';

class CardPreview extends StatelessWidget {
  final String name;
  final String type;
  final String price;
  final String? imageUrl;
  final CardRarity rarity;
  final bool isSmall;
  final VoidCallback? onTap;

  const CardPreview({
    super.key,
    required this.name,
    required this.type,
    required this.price,
    this.imageUrl,
    this.rarity = CardRarity.common,
    this.isSmall = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = isSmall ? 120.0 : 200.0;
    final cardWidth = cardHeight * 0.715; // Proporción 63x88mm de cartas MTG

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Imagen de la carta o placeholder
              Positioned.fill(
                child: imageUrl != null
                    ? imageUrl!.startsWith('assets/')
                          ? Image.asset(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(),
                            )
                          : Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(),
                            )
                    : _buildMockCard(),
              ),

              // Badge de rareza
              if (!isSmall)
                Positioned(top: 8, right: 8, child: _buildRarityBadge()),

              // Información en la parte inferior
              if (!isSmall)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildCardInfo(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockCard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        ),
      ),
      child: Column(
        children: [
          // Header de la carta mock
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: isSmall ? 9 : 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Contenido central - simulamos una imagen
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(_getCardIcon(), color: Colors.white, size: 32),
              ),
            ),
          ),

          // Footer con tipo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9)),
            child: Text(
              type,
              style: TextStyle(
                fontSize: isSmall ? 8 : 9,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 48,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildRarityBadge() {
    return CardRarityTag(rarity: rarity);
  }

  Widget _buildCardInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            type,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCardIcon() {
    final lowerType = type.toLowerCase();

    if (lowerType.contains('creature')) {
      return Icons.person; // Ícono para criaturas
    } else if (lowerType.contains('land')) {
      return Icons.landscape; // Ícono para tierras
    } else if (lowerType.contains('instant') || lowerType.contains('sorcery')) {
      return Icons.flash_on; // Ícono para hechizos
    } else if (lowerType.contains('artifact')) {
      return Icons.settings; // Ícono para artefactos
    } else if (lowerType.contains('enchantment')) {
      return Icons.auto_awesome; // Ícono para encantamientos
    } else {
      return Icons.star; // Ícono genérico
    }
  }
}
