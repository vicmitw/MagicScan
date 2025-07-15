import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../domain/entities/scan_result.dart';

/// Widget específico para el marco de captura de cartas
/// Siguiendo el Single Responsibility Principle (SRP)
class CameraFrameOverlay extends StatefulWidget {
  final bool isScanning;
  final ScanType scanType;
  final String? instructionText;

  const CameraFrameOverlay({
    super.key,
    required this.isScanning,
    required this.scanType,
    this.instructionText,
  });

  @override
  State<CameraFrameOverlay> createState() => _CameraFrameOverlayState();
}

class _CameraFrameOverlayState extends State<CameraFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _initScanLineAnimation();
  }

  void _initScanLineAnimation() {
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );

    _scanLineController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
        ),
        child: Center(
          child: _buildCardFrame(),
        ),
      ),
    );
  }

  Widget _buildCardFrame() {
    const frameWidth = 280.0;
    const frameHeight = 390.0; // Proporción MTG: 63mm x 88mm

    return Container(
      width: frameWidth,
      height: frameHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isScanning ? AppColors.success : AppColors.primary,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (widget.isScanning ? AppColors.success : AppColors.primary)
                .withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Esquinas del marco
          ..._buildFrameCorners(),
          
          // Línea de escaneo
          if (widget.isScanning) _buildScanLine(),
          
          // Texto de instrucciones
          _buildInstructionText(),
        ],
      ),
    );
  }

  List<Widget> _buildFrameCorners() {
    const cornerLength = 30.0;
    const cornerWidth = 4.0;
    final color = widget.isScanning ? AppColors.success : AppColors.primary;

    return [
      // Esquina superior izquierda
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerLength,
          height: cornerWidth,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
            ),
          ),
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerWidth,
          height: cornerLength,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
            ),
          ),
        ),
      ),
      
      // Esquina superior derecha
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerLength,
          height: cornerWidth,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
            ),
          ),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerWidth,
          height: cornerLength,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
            ),
          ),
        ),
      ),
      
      // Esquina inferior izquierda
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerLength,
          height: cornerWidth,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerWidth,
          height: cornerLength,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
            ),
          ),
        ),
      ),
      
      // Esquina inferior derecha
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerLength,
          height: cornerWidth,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerWidth,
          height: cornerLength,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        return Positioned(
          top: 390 * _scanLineAnimation.value - 2,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.success,
                  AppColors.success,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionText() {
    return Positioned(
      bottom: -60,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            widget.instructionText ?? _getDefaultInstructionText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isScanning ? 'Procesando...' : 'Toca el botón para escanear',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDefaultInstructionText() {
    switch (widget.scanType) {
      case ScanType.quickScan:
        return 'Coloca la carta en el marco';
      case ScanType.freeScan:
        return 'Escanea todas las cartas del mazo';
    }
  }
} 