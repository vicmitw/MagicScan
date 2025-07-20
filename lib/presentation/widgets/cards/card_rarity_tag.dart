import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum CardRarity {
  common,
  uncommon,
  rare,
  mythic,
}

extension RarityExtension on CardRarity {
  Color get color {
    switch (this) {
      case CardRarity.common:
        return AppColors.textSecondary;
      case CardRarity.uncommon:
        return Colors.blueGrey;
      case CardRarity.rare:
        return Colors.amber.shade700;
      case CardRarity.mythic:
        return Colors.deepOrange.shade600;
      default:
        return AppColors.textSecondary;
    }
  }

  String get name {
    switch (this) {
      case CardRarity.common:
        return 'Common';
      case CardRarity.uncommon:
        return 'Uncommon';
      case CardRarity.rare:
        return 'Rare';
      case CardRarity.mythic:
        return 'Mythic';
      default:
        return 'Common';
    }
  }
}

extension RarityStringExtension on String {
  CardRarity toCardRarity() {
    switch (toLowerCase()) {
      case 'common':
        return CardRarity.common;
      case 'uncommon':
        return CardRarity.uncommon;
      case 'rare':
        return CardRarity.rare;
      case 'mythic':
        return CardRarity.mythic;
      default:
        return CardRarity.common;
    }
  }
}

class CardRarityTag extends StatelessWidget {
  final CardRarity rarity;

  const CardRarityTag({super.key, required this.rarity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rarity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: rarity.color, width: 1),
      ),
      child: Text(
        rarity.name,
        style: TextStyle(
          color: rarity.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
} 