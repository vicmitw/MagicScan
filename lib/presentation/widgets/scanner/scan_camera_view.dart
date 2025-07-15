import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../theme/app_colors.dart';
import '../../../data/models/scan_result.dart';
import '../../../data/services/camera_service.dart';

/// Widget que muestra la vista de cámara con marco de captura
class ScanCameraView extends StatefulWidget {
  final ScanType scanType;
  final Function(ScanResult) onScanResult;
  final VoidCallback? onClose;

  const ScanCameraView({
    super.key,
    required this.scanType,
    required this.onScanResult,
    this.onClose,
  });

  @override
  State<ScanCameraView> createState() => _ScanCameraViewState();
}

class _ScanCameraViewState extends State<ScanCameraView>
    with TickerProviderStateMixin {
  final CameraService _cameraService = CameraService.instance;

  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  bool _isInitialized = false;
  bool _isScanning = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeCamera();
  }

  void _initAnimations() {
    // Animación de línea de escaneo
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Repetir animación de escaneo
    _scanAnimationController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final success = await _cameraService.initialize();
    if (success && mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista de cámara
          if (_isInitialized && _cameraService.controller != null)
            Positioned.fill(child: CameraPreview(_cameraService.controller!)),

          // Overlay con marco de captura
          _buildCameraOverlay(),

          // Controles superiores
          _buildTopControls(),

          // Controles inferiores
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
        child: Stack(
          children: [
            // Marco de captura fijo (sin animación)
            Center(
              child: Container(
                width: 280,
                height: 390, // Proporción típica de carta MTG (63mm x 88mm)
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isScanning
                        ? AppColors.success
                        : AppColors.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isScanning
                                  ? AppColors.success
                                  : AppColors.primary)
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
                    if (_isScanning) _buildScanLine(),

                    // Texto de instrucciones
                    _buildInstructionText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFrameCorners() {
    const cornerLength = 30.0;
    const cornerWidth = 4.0;
    final color = _isScanning ? AppColors.success : AppColors.primary;

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
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
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
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
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
      animation: _scanAnimation,
      builder: (context, child) {
        return Positioned(
          top: 390 * _scanAnimation.value - 2,
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
            widget.scanType == ScanType.quickScan
                ? 'Coloca la carta en el marco'
                : 'Escanea todas las cartas del mazo',
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
            _isScanning ? 'Procesando...' : 'Toca el botón para escanear',
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

  Widget _buildTopControls() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón cerrar
          _buildControlButton(icon: Icons.close, onPressed: widget.onClose),

          // Título
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.scanType.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Botón flash
          _buildControlButton(
            icon: _flashMode == FlashMode.off
                ? Icons.flash_off
                : Icons.flash_on,
            onPressed: _toggleFlash,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 32,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón cambiar cámara
          _buildControlButton(
            icon: Icons.flip_camera_android,
            onPressed: _switchCamera,
          ),

          // Botón de captura
          GestureDetector(
            onTap: _isScanning ? null : _capture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isScanning ? Colors.grey : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isScanning ? Icons.hourglass_empty : Icons.camera_alt,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Spacer para balancear
          const SizedBox(width: 56),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _capture() async {
    if (!_isInitialized || _isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final result = await _cameraService.captureAndProcess(widget.scanType);
      widget.onScanResult(result);
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      _flashMode = _flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;
    });
    _cameraService.setFlashMode(_flashMode);
  }

  void _switchCamera() {
    _cameraService.switchCamera();
  }
}
