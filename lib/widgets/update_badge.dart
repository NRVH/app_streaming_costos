import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/update_provider.dart';
import '../services/update_service.dart';
import 'update_dialog.dart';

class UpdateBadge extends ConsumerWidget {
  const UpdateBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);

    // No mostrar si no hay actualización
    if (!updateState.hasUpdate) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Badge(
        backgroundColor: Colors.amber,
        label: const Text('1'),
        child: const Icon(Icons.system_update),
      ),
      tooltip: 'Actualización disponible',
      onPressed: () async {
        final updateService = UpdateService();
        final currentVersion = await updateService.getCurrentVersion();
        
        if (context.mounted) {
          showUpdateDialog(
            context,
            updateState.availableUpdate!,
            currentVersion,
          );
        }
      },
    );
  }
}
