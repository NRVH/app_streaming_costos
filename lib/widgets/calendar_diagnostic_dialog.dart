import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_calendar/device_calendar.dart';
import '../services/calendar_service.dart';

/// Diálogo de diagnóstico detallado de calendarios
class CalendarDiagnosticDialog extends StatefulWidget {
  const CalendarDiagnosticDialog({super.key});

  @override
  State<CalendarDiagnosticDialog> createState() => _CalendarDiagnosticDialogState();
}

class _CalendarDiagnosticDialogState extends State<CalendarDiagnosticDialog> {
  final CalendarService _calendarService = CalendarService();
  bool _isLoading = true;
  Map<String, dynamic> _diagnosticInfo = {};

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    setState(() => _isLoading = true);

    final info = <String, dynamic>{};

    try {
      // 1. Verificar permisos
      info['hasPermissions'] = await _calendarService.hasPermissions();
      
      if (!info['hasPermissions']) {
        info['requestPermissionsResult'] = await _calendarService.requestPermissions();
      }

      // 2. Obtener todos los calendarios (sin filtro)
      final plugin = DeviceCalendarPlugin();
      final calendarsResult = await plugin.retrieveCalendars();
      
      info['retrieveSuccess'] = calendarsResult.isSuccess;
      info['hasData'] = calendarsResult.data != null;
      info['rawCount'] = calendarsResult.data?.length ?? 0;
      
      if (!calendarsResult.isSuccess) {
        info['errors'] = 'API call failed';
      }

      if (calendarsResult.data != null) {
        final allCalendars = calendarsResult.data!;
        final calendarsDetails = <Map<String, dynamic>>[];
        
        for (var cal in allCalendars) {
          calendarsDetails.add({
            'id': cal.id,
            'name': cal.name,
            'accountName': cal.accountName,
            'accountType': cal.accountType,
            'isReadOnly': cal.isReadOnly,
            'isDefault': cal.isDefault,
            'color': cal.color,
          });
        }
        
        info['calendars'] = calendarsDetails;
        info['editableCalendars'] = allCalendars.where((c) => c.isReadOnly == false).length;
        info['readOnlyCalendars'] = allCalendars.where((c) => c.isReadOnly == true).length;
      }

    } catch (e, stackTrace) {
      info['exception'] = e.toString();
      info['stackTrace'] = stackTrace.toString().split('\n').take(5).join('\n');
    }

    setState(() {
      _diagnosticInfo = info;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.bug_report, color: Colors.purple),
          const SizedBox(width: 12),
          const Expanded(child: Text('Diagnóstico de Calendarios')),
        ],
      ),
      content: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSection('🔐 Permisos', [
                    _buildItem('Tiene permisos', _diagnosticInfo['hasPermissions'] ?? false),
                    if (_diagnosticInfo['requestPermissionsResult'] != null)
                      _buildItem('Solicitud de permisos', _diagnosticInfo['requestPermissionsResult']),
                  ]),
                  const Divider(height: 24),
                  _buildSection('📋 Resultado de API', [
                    _buildItem('Consulta exitosa', _diagnosticInfo['retrieveSuccess'] ?? false),
                    _buildItem('Tiene datos', _diagnosticInfo['hasData'] ?? false),
                    _buildItem('Total calendarios', _diagnosticInfo['totalCalendars'] ?? 0),
                    if (_diagnosticInfo['errors'] != null)
                      _buildErrorItem('Errores', _diagnosticInfo['errors']),
                  ]),
                  if (_diagnosticInfo['totalCalendars'] != null && _diagnosticInfo['totalCalendars'] > 0) ...[
                    const Divider(height: 24),
                    _buildSection('📊 Resumen', [
                      _buildItem('✅ Editables', _diagnosticInfo['editableCalendars'] ?? 0),
                      _buildItem('🔒 Solo lectura', _diagnosticInfo['readOnlyCalendars'] ?? 0),
                    ]),
                    const Divider(height: 24),
                    _buildSection('📅 Calendarios Detectados', 
                      (_diagnosticInfo['calendars'] as List<Map<String, dynamic>>?)
                          ?.map((cal) => _buildCalendarCard(cal))
                          .toList() ?? [],
                    ),
                  ],
                  if (_diagnosticInfo['exception'] != null) ...[
                    const Divider(height: 24),
                    _buildSection('❌ Excepción', [
                      _buildErrorItem('Error', _diagnosticInfo['exception']),
                      _buildErrorItem('Stack', _diagnosticInfo['stackTrace'], mono: true),
                    ]),
                  ],
                  if (_diagnosticInfo['totalCalendars'] == 0) ...[
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text(
                                'No hay calendarios',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Posibles causas:\n\n'
                            '1. No tienes cuentas sincronizadas (Google, Samsung, etc.)\n'
                            '2. Las cuentas no tienen calendarios creados\n'
                            '3. La sincronización de calendario está desactivada\n'
                            '4. El sistema no tiene acceso a los calendarios\n\n'
                            'Solución:\n'
                            '• Abre Google Calendar o Samsung Calendar\n'
                            '• Verifica que tengas cuentas agregadas\n'
                            '• Activa la sincronización de calendario\n'
                            '• Crea al menos un calendario',
                            style: TextStyle(fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            // Copiar diagnóstico al portapapeles
            final text = _diagnosticInfo.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n');
            Clipboard.setData(ClipboardData(text: text));
          },
          child: const Text('Copiar'),
        ),
        TextButton(
          onPressed: _runDiagnostic,
          child: const Text('Reintentar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildItem(String label, dynamic value) {
    final isGood = value is bool ? value : (value is int ? value > 0 : true);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isGood ? Icons.check_circle : Icons.cancel,
            color: isGood ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$label: $value'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(String label, dynamic value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              value.toString(),
              style: TextStyle(
                fontSize: 12,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(Map<String, dynamic> cal) {
    final isReadOnly = cal['isReadOnly'] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReadOnly
            ? Colors.grey.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReadOnly ? Colors.grey : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: cal['color'] != null
                      ? Color(cal['color'])
                      : Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cal['name'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (cal['isDefault'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCalendarInfo('👤 Cuenta', cal['accountName'] ?? 'Desconocida'),
          _buildCalendarInfo('🏢 Tipo', cal['accountType'] ?? 'Desconocido'),
          _buildCalendarInfo('🔒 Modo', isReadOnly ? 'Solo lectura' : 'Editable'),
          _buildCalendarInfo('🆔 ID', cal['id'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildCalendarInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

/// Función auxiliar para mostrar el diálogo
Future<void> showCalendarDiagnosticDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const CalendarDiagnosticDialog(),
  );
}
