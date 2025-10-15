import 'package:flutter/material.dart';

/// Diálogo de ayuda cuando no se encuentran calendarios
class NoCalendarHelpDialog extends StatelessWidget {
  const NoCalendarHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No hay calendarios disponibles',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SubTrack no puede encontrar calendarios sincronizados con el sistema Android.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Usas Samsung Calendar, Outlook u otra app de calendario?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Pasos para sincronizar:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStep('1', 'Abre tu app de Calendario', Icons.calendar_month),
                  const SizedBox(height: 12),
                  _buildStep('2', 'Ve a Configuración (⚙️) o Menú (☰)', Icons.settings),
                  const SizedBox(height: 12),
                  _buildStep('3', 'Busca "Cuentas" o "Sincronización"', Icons.sync),
                  const SizedBox(height: 12),
                  _buildStep('4', 'Agrega una cuenta:\n  • Google\n  • Samsung\n  • Microsoft/Outlook', Icons.account_circle),
                  const SizedBox(height: 12),
                  _buildStep('5', 'Activa sincronización de calendario ✓', Icons.cloud_sync),
                  const SizedBox(height: 12),
                  _buildStep('6', 'Vuelve a SubTrack y presiona "Reintentar"', Icons.refresh),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dato importante: SubTrack funciona con calendarios sincronizados con el sistema Android. Las apps de calendario que funcionan de forma independiente (sin sincronización) no serán detectadas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green[700], size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Apps compatibles:\n• Google Calendar\n• Samsung Calendar (con cuenta)\n• Outlook Calendar\n• Cualquier calendario sincronizado',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }

  static Widget _buildStep(String number, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
        ),
      ],
    );
  }
}

/// Función auxiliar para mostrar el diálogo
Future<bool?> showNoCalendarHelpDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const NoCalendarHelpDialog(),
  );
}
