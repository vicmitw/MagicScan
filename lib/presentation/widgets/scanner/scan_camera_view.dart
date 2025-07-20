import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../theme/app_colors.dart';
import '../../../domain/entities/scan_result.dart';
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

  /// Maneja el tap to focus en la cámara
  void _handleTapToFocus(TapDownDetails details) async {
    if (!_isInitialized || _cameraService.controller == null) return;
    
    final controller = _cameraService.controller!;
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Convertir coordenadas de pantalla a coordenadas de cámara (0.0 - 1.0)
    final normalizedX = localPosition.dx / renderBox.size.width;
    final normalizedY = localPosition.dy / renderBox.size.height;
    
    try {
      await controller.setFocusPoint(Offset(normalizedX, normalizedY));
      await controller.setExposurePoint(Offset(normalizedX, normalizedY));
      debugPrint('👆 Focus ajustado a: ($normalizedX, $normalizedY)');
    } catch (e) {
      debugPrint('❌ Error al ajustar focus: $e');
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
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          _handleTapToFocus(details);
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
          child: Stack(
            children: [
            // Marco de captura fijo (sin animación)
            Center(
              child: Container(
                width: 240,
                height: 336, // Proporción más precisa de carta MTG (ratio 5:7)
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
      ),
    );
  }

  List<Widget> _buildFrameCorners() {
    const cornerSize = 24.0;
    const cornerThickness = 4.0;
    final cornerColor = _isScanning ? AppColors.success : AppColors.primary;

    return [
      // Esquina superior izquierda
      Positioned(
        top: 0,
        left: 0,
        child: CustomPaint(
          size: const Size(cornerSize, cornerSize),
          painter: CornerPainter(
            color: cornerColor,
            thickness: cornerThickness,
            isTopLeft: true,
          ),
        ),
      ),
      // Esquina superior derecha
      Positioned(
        top: 0,
        right: 0,
        child: CustomPaint(
          size: const Size(cornerSize, cornerSize),
          painter: CornerPainter(
            color: cornerColor,
            thickness: cornerThickness,
            isTopRight: true,
          ),
        ),
      ),
      // Esquina inferior izquierda
      Positioned(
        bottom: 0,
        left: 0,
        child: CustomPaint(
          size: const Size(cornerSize, cornerSize),
          painter: CornerPainter(
            color: cornerColor,
            thickness: cornerThickness,
            isBottomLeft: true,
          ),
        ),
      ),
      // Esquina inferior derecha
      Positioned(
        bottom: 0,
        right: 0,
        child: CustomPaint(
          size: const Size(cornerSize, cornerSize),
          painter: CornerPainter(
            color: cornerColor,
            thickness: cornerThickness,
            isBottomRight: true,
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
          top: _scanAnimation.value * (390 - 3), // Altura del marco - grosor línea
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.success.withOpacity(0.8),
                  AppColors.success,
                  AppColors.success.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.6),
                  blurRadius: 8,
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
    String instruction = _isScanning
        ? 'Analizando carta...'
        : 'Coloca la carta dentro del marco';

    return Positioned(
      bottom: -60,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          instruction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.black.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botón de Galería (placeholder)
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              color: Colors.white,
              iconSize: 32,
              onPressed: () {
                // TODO: Implementar selección desde galería
              },
            ),

            // Botón de Captura principal
            GestureDetector(
              onTap: _handleScanButtonPressed,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 4),
                ),
              ),
            ),

            // Botón de Multi-Scan (placeholder)
            IconButton(
              icon: const Icon(Icons.filter_none_outlined),
              color: Colors.white,
              iconSize: 32,
              onPressed: () {
                // TODO: Implementar modo multi-scan
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleScanButtonPressed() async {
    // Usar el sistema real de captura y procesamiento
    if (!_isInitialized || _isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      // Llamar al motor real de scanning
      final result = await _cameraService.captureAndProcess(widget.scanType);
      
      // El resultado se mostrará en consola por el CameraService
      // También pasamos el resultado al callback para mantener la UI
      widget.onScanResult(result);
    } catch (e) {
      debugPrint('❌ Error en scanning: $e');
      final errorResult = ScanResult.error(
        error: 'Error en scanning: $e',
        scanType: widget.scanType,
      );
      widget.onScanResult(errorResult);
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
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

  Future<void> _toggleFlash() async {
    // Alternar estado del flash
    final newFlashMode = _flashMode == FlashMode.off 
        ? FlashMode.torch 
        : FlashMode.off;

    try {
      await _cameraService.controller?.setFlashMode(newFlashMode);
      if (mounted) {
        setState(() {
          _flashMode = newFlashMode;
        });
      }
    } catch (e) {
      debugPrint('Error al cambiar flash: $e');
    }
  }
}

// Painter personalizado para las esquinas del marco
class CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  CornerPainter({
    required this.color,
    required this.thickness,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    const cornerLength = 16.0;

    if (isTopLeft) {
      // Línea horizontal superior
      canvas.drawLine(
        const Offset(0, 0),
        const Offset(cornerLength, 0),
        paint,
      );
      // Línea vertical izquierda
      canvas.drawLine(
        const Offset(0, 0),
        const Offset(0, cornerLength),
        paint,
      );
    }

    if (isTopRight) {
      // Línea horizontal superior
      canvas.drawLine(
        Offset(size.width, 0),
        Offset(size.width - cornerLength, 0),
        paint,
      );
      // Línea vertical derecha
      canvas.drawLine(
        Offset(size.width, 0),
        Offset(size.width, cornerLength),
        paint,
      );
    }

    if (isBottomLeft) {
      // Línea horizontal inferior
      canvas.drawLine(
        Offset(0, size.height),
        Offset(cornerLength, size.height),
        paint,
      );
      // Línea vertical izquierda
      canvas.drawLine(
        Offset(0, size.height),
        Offset(0, size.height - cornerLength),
        paint,
      );
    }

    if (isBottomRight) {
      // Línea horizontal inferior
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height),
        paint,
      );
      // Línea vertical derecha
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
