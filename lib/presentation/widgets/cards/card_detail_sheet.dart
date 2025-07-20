import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:magicscan/domain/entities/scanned_card.dart';
import 'package:magicscan/presentation/theme/app_colors.dart';
import 'package:magicscan/presentation/widgets/cards/card_preview.dart';
import 'package:magicscan/presentation/widgets/cards/card_rarity_tag.dart';

class CardDetailSheet extends StatelessWidget {
  final ScannedCard card;

  const CardDetailSheet({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              CardPreview(
                name: card.name,
                type: card.type ?? 'Tipo no disponible',
                price: card.priceFormatted ?? 'N/A',
                rarity: card.rarity?.toCardRarity() ?? CardRarity.common,
                imageUrl: card.imageUrl ?? 'assets/images/placeholder.png',
              ),
              const SizedBox(height: 24),
              const Text(
                'Detalles',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const Divider(height: 20, color: AppColors.textSecondary),
              _buildDetailRow('Coste de Maná', card.manaCost ?? 'No disponible'),
              _buildDetailRow('Set', card.set ?? 'No disponible'),
              _buildDetailRow('Precio', card.priceFormatted ?? 'No disponible'),
              if (card.description != null && card.description!.isNotEmpty)
                _buildDescriptionSection(card.description!),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Descripción',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 