import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

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
              Icon(Icons.camera_alt, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Motor de Scanning',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Próximamente: Reconocimiento avanzado\nde cartas MTG con IA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '🔮 Funcionalidad en desarrollo\nPronto podrás escanear cartas reales',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
