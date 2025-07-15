import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/app_colors.dart';
import '../../../data/models/scanned_card.dart';
import '../../../data/models/scan_result.dart';
import '../cards/card_preview.dart';

/// Popup que muestra el resultado del escaneo con información de la carta
class ScanResultPopup extends StatefulWidget {
  final ScannedCard card;
  final ScanType scanType;
  final VoidCallback onComplete;
  final Duration duration;

  const ScanResultPopup({
    super.key,
    required this.card,
    required this.scanType,
    required this.onComplete,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<ScanResultPopup> createState() => _ScanResultPopupState();
}

class _ScanResultPopupState extends State<ScanResultPopup>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // Animación de entrada
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.bounceOut),
        );

    // Animación de progreso
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Animación de pulso para el precio
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _slideController.forward();
    _progressController.forward();
    _pulseController.repeat(reverse: true);

    // Completar cuando termine el progreso
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onComplete();
      }
    });
  }

  void _onComplete() {
    _slideController.reverse().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Fondo semi-transparente
          Container(
            color: Colors.black.withOpacity(0.5),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Popup principal
          Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 340),
                child: _buildPopupContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildCardInfo(),
              _buildProgressBar(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                widget.scanType == ScanType.quickScan
                    ? Icons.flash_on
                    : Icons.scanner,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '¡Carta Detectada!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.speed, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text(
                'Confianza: ${(widget.card.confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Imagen de la carta
          Container(
            width: 120,
            height: 168,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.card.imageUrl != null
                  ? Image.asset(
                      widget.card.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.surface,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Información de la carta
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.card.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              if (widget.card.type != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.card.type!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (widget.card.set != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.card.set!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 16),

              // Precio destacado
              if (widget.card.priceFormatted != null)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success.withOpacity(0.1),
                              AppColors.success.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.card.priceFormatted!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.scanType == ScanType.quickScan
                    ? 'Procesando...'
                    : 'Listo para siguiente carta',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final remainingTime =
                      (_progressAnimation.value * widget.duration.inSeconds)
                          .ceil();
                  return Text(
                    '${remainingTime}s',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de progreso
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1.0 - _progressAnimation.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progressAnimation.value > 0.3
                          ? AppColors.primary
                          : AppColors.warning,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _onComplete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Función utilitaria para mostrar el popup
void showScanResultPopup({
  required BuildContext context,
  required ScannedCard card,
  required ScanType scanType,
  required VoidCallback onComplete,
  Duration duration = const Duration(seconds: 4),
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => ScanResultPopup(
      card: card,
      scanType: scanType,
      onComplete: () {
        Navigator.of(context).pop();
        onComplete();
      },
      duration: duration,
    ),
  );
}
