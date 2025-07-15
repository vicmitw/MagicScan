import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PacksPage extends StatelessWidget {
  const PacksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.glassBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2, size: 80, color: AppColors.secondary),
              const SizedBox(height: 24),
              Text(
                'Sobres',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Análisis avanzado de ROI\ny rentabilidad de sobres',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '💎 Funcionalidad Premium\nPróximamente disponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
