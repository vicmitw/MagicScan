import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magicscan/presentation/theme/app_colors.dart';

/// Muestra un diálogo para que el usuario seleccione manually una carta
/// cuando el reconocimiento automático tiene baja confianza.
///
/// El diálogo tiene dos pasos:
/// 1. Muestra una rejilla con las posibles cartas candidatas.
/// 2. Al seleccionar una, muestra una vista de confirmación para esa carta.
Future<void> showManualCardSelectionDialog(
    BuildContext context, List<String> cardImagePaths) async {
  // Rastreador de estado para la carta seleccionada. Usamos un ValueNotifier
  // para poder reconstruir solo el contenido del diálogo con un `StatefulBuilder`.
  final selectedCardNotifier = ValueNotifier<String?>(null);

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return ValueListenableBuilder<String?>(
        valueListenable: selectedCardNotifier,
        builder: (context, selectedCard, child) {
          final isConfirmationView = selectedCard != null;

          return AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
            ),
            title: Text(
              isConfirmationView
                  ? 'Confirmar Selección'
                  : 'Selección Manual',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: isConfirmationView
                  ? _build_confirmation_view(
                      context,
                      selectedCard,
                      () => selectedCardNotifier.value = null,
                    )
                  : _build_grid_view(
                      cardImagePaths,
                      (path) => selectedCardNotifier.value = path,
                    ),
            ),
          );
        },
      );
    },
  );
}

/// Vista de la rejilla de selección de cartas.
Widget _build_grid_view(
  List<String> cardImagePaths,
  ValueSetter<String> onCardSelected,
) {
  return Builder(builder: (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No pudimos identificar la carta con total seguridad. Por favor, selecciónala de la lista:',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 63 / 88, // Proporción de una carta de Magic
            ),
            itemCount: cardImagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = cardImagePaths[index];
              return GestureDetector(
                onTap: () => onCardSelected(imagePath),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  });
}

/// Vista de confirmación para la carta seleccionada.
Widget _build_confirmation_view(
  BuildContext context,
  String selectedCardPath,
  VoidCallback onGoBack,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '¿Confirmas que esta es la carta escaneada?',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            selectedCardPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            icon: const Icon(CupertinoIcons.arrow_left, size: 18),
            label: const Text('Volver'),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color),
            onPressed: onGoBack,
          ),
          ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.check_mark_circled, size: 18),
            label: const Text('Confirmar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // TODO: Lógica de confirmación final
              // Por ejemplo, guardar la carta en la colección.
              Navigator.of(context).pop(); // Cierra el diálogo
            },
          ),
        ],
      )
    ],
  );
} 