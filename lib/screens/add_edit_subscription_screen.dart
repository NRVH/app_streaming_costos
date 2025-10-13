import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription_model.dart';
import '../providers/subscriptions_provider.dart';
import '../services/calendar_service.dart';
import '../core/constants/app_constants.dart';

class AddEditSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? subscription;

  const AddEditSubscriptionScreen({
    super.key,
    this.subscription,
  });

  @override
  ConsumerState<AddEditSubscriptionScreen> createState() => _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends ConsumerState<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  
  late String _selectedCategory;
  late BillingCycle _selectedBillingCycle;
  late DateTime _selectedBillingDate;
  late Color _selectedColor;
  late bool _reminderEnabled;
  late int _reminderDaysBefore;
  late bool _reminderAllDay;
  late TimeOfDay _reminderTime;
  late int? _subscriptionDurationMonths; // null = indefinido
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.subscription != null) {
      // Modo edición
      _nameController.text = widget.subscription!.name;
      _priceController.text = widget.subscription!.price.toString();
      _notesController.text = widget.subscription!.notes ?? '';
      _selectedCategory = widget.subscription!.category;
      _selectedBillingCycle = widget.subscription!.billingCycle;
      _selectedBillingDate = widget.subscription!.billingDate;
      _selectedColor = Color(widget.subscription!.colorValue);
      _reminderEnabled = widget.subscription!.reminderEnabled;
      _reminderDaysBefore = widget.subscription!.reminderDaysBefore;
      _reminderAllDay = widget.subscription!.reminderAllDay;
      _reminderTime = TimeOfDay(
        hour: widget.subscription!.reminderHour ?? 9,
        minute: widget.subscription!.reminderMinute ?? 0,
      );
      // Calcular duración en meses si tiene fecha de fin
      if (widget.subscription!.subscriptionEndDate != null) {
        final months = widget.subscription!.subscriptionEndDate!
            .difference(widget.subscription!.billingDate)
            .inDays ~/ 30;
        
        // Ajustar al valor más cercano disponible en el dropdown
        if (months <= 0) {
          _subscriptionDurationMonths = 1;
        } else if (months <= 2) {
          _subscriptionDurationMonths = 1;
        } else if (months <= 4) {
          _subscriptionDurationMonths = 3;
        } else if (months <= 9) {
          _subscriptionDurationMonths = 6;
        } else if (months <= 18) {
          _subscriptionDurationMonths = 12;
        } else {
          _subscriptionDurationMonths = 24;
        }
      } else {
        _subscriptionDurationMonths = null; // Indefinido
      }
    } else {
      // Modo creación
      _selectedCategory = AppConstants.categories.first;
      _selectedBillingCycle = BillingCycle.monthly;
      _selectedBillingDate = DateTime.now();
      _selectedColor = Colors.blue;
      _reminderEnabled = true;
      _reminderDaysBefore = AppConstants.reminderDaysBefore;
      _reminderAllDay = false; // Por defecto: hora específica
      _reminderTime = const TimeOfDay(hour: 9, minute: 0); // 9:00 AM por defecto
      _subscriptionDurationMonths = 12; // Por defecto 1 año
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription == null ? 'Nueva Suscripción' : 'Editar Suscripción'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selector de servicio popular
            _buildPopularServicesSection(),
            const SizedBox(height: 24),
            
            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la suscripción',
                hintText: 'Ej: Netflix, Spotify',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Precio
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Precio',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: AppConstants.defaultCurrency,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un precio';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Categoría
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Frecuencia de cobro
            DropdownButtonFormField<BillingCycle>(
              value: _selectedBillingCycle,
              decoration: const InputDecoration(
                labelText: 'Frecuencia de cobro',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: BillingCycle.values.map((cycle) {
                return DropdownMenuItem(
                  value: cycle,
                  child: Text(cycle.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBillingCycle = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Fecha de cobro
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceVariant,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de cobro'),
              subtitle: Text(
                '${_selectedBillingDate.day}/${_selectedBillingDate.month}/${_selectedBillingDate.year}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedBillingDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _selectedBillingDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Color
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceVariant,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
              ),
              title: const Text('Color'),
              subtitle: const Text('Toca para cambiar'),
              onTap: () => _showColorPicker(),
            ),
            const SizedBox(height: 24),
            
            // Recordatorios
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recordatorios',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _reminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          _reminderEnabled = value;
                        });
                      },
                      title: const Text('Habilitar recordatorio'),
                      subtitle: const Text('Crear evento en calendario'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_reminderEnabled) ...[
                      const SizedBox(height: 16),
                      
                      // Días de anticipación (ahora incluye 0 = mismo día)
                      DropdownButtonFormField<int>(
                        value: _reminderDaysBefore,
                        decoration: const InputDecoration(
                          labelText: 'Recordar con anticipación',
                          prefixIcon: Icon(Icons.calendar_today),
                          isDense: true,
                        ),
                        items: [0, 1, 2, 3, 5, 7].map((days) {
                          return DropdownMenuItem(
                            value: days,
                            child: Text(days == 0 
                                ? 'El mismo día' 
                                : '$days ${days == 1 ? 'día' : 'días'} antes'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _reminderDaysBefore = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Todo el día o hora específica
                      SwitchListTile(
                        value: _reminderAllDay,
                        onChanged: (value) {
                          setState(() {
                            _reminderAllDay = value;
                          });
                        },
                        title: const Text('Recordatorio todo el día'),
                        subtitle: Text(_reminderAllDay 
                            ? 'Sin hora específica' 
                            : 'Hora específica: ${_reminderTime.format(context)}'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      // Selector de hora (solo si NO es todo el día)
                      if (!_reminderAllDay) ...[
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.access_time),
                          title: const Text('Hora del recordatorio'),
                          subtitle: Text(_reminderTime.format(context)),
                          trailing: const Icon(Icons.edit),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _reminderTime,
                              builder: (context, child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    alwaysUse24HourFormat: false,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _reminderTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Duración de la suscripción
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Duración de la suscripción',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los recordatorios se crearán solo hasta la fecha de fin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: _subscriptionDurationMonths,
                      decoration: const InputDecoration(
                        labelText: 'Duración',
                        prefixIcon: Icon(Icons.timelapse),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Indefinida (sin límite)'),
                        ),
                        const DropdownMenuItem(
                          value: 1,
                          child: Text('1 mes'),
                        ),
                        const DropdownMenuItem(
                          value: 3,
                          child: Text('3 meses'),
                        ),
                        const DropdownMenuItem(
                          value: 6,
                          child: Text('6 meses'),
                        ),
                        const DropdownMenuItem(
                          value: 12,
                          child: Text('1 año (12 meses)'),
                        ),
                        const DropdownMenuItem(
                          value: 24,
                          child: Text('2 años (24 meses)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _subscriptionDurationMonths = value;
                        });
                      },
                    ),
                    if (_subscriptionDurationMonths != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'La suscripción expirará el ${_getEndDate().day}/${_getEndDate().month}/${_getEndDate().year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Información adicional',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            
            // Botón guardar
            FilledButton(
              onPressed: _isLoading ? null : _saveSubscription,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.subscription == null ? 'Agregar Suscripción' : 'Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _getEndDate() {
    if (_subscriptionDurationMonths == null) {
      return _selectedBillingDate.add(const Duration(days: 365)); // Solo para preview
    }
    return DateTime(
      _selectedBillingDate.year,
      _selectedBillingDate.month + _subscriptionDurationMonths!,
      _selectedBillingDate.day,
    );
  }

  Widget _buildPopularServicesSection() {
    if (widget.subscription != null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios Populares',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.popularServices.keys.take(8).map((service) {
            return ActionChip(
              label: Text(service),
              onPressed: () {
                _nameController.text = service;
                _selectedCategory = AppConstants.popularServices[service]!;
                if (AppConstants.serviceColors.containsKey(service)) {
                  _selectedColor = Color(AppConstants.serviceColors[service]!);
                }
                setState(() {});
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showColorPicker() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona un color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == color
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: _selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    print('🔵 [SAVE] Iniciando guardado de suscripción...');
    print('🔵 [SAVE] Nombre: ${_nameController.text.trim()}');
    print('🔵 [SAVE] Precio: ${_priceController.text.trim()}');
    print('🔵 [SAVE] Categoría: $_selectedCategory');
    print('🔵 [SAVE] Duración meses: $_subscriptionDurationMonths');
    print('🔵 [SAVE] Reminder enabled: $_reminderEnabled');
    print('🔵 [SAVE] Reminder all day: $_reminderAllDay');
    print('🔵 [SAVE] Reminder hour: ${_reminderTime.hour}');
    print('🔵 [SAVE] Reminder minute: ${_reminderTime.minute}');

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔵 [SAVE] Creando objeto Subscription...');
      final subscription = Subscription(
        id: widget.subscription?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        currency: AppConstants.defaultCurrency,
        category: _selectedCategory,
        colorValue: _selectedColor.value,
        billingDate: _selectedBillingDate,
        billingCycle: _selectedBillingCycle,
        reminderEnabled: _reminderEnabled,
        reminderDaysBefore: _reminderDaysBefore,
        reminderAllDay: _reminderAllDay,
        reminderHour: _reminderAllDay ? null : _reminderTime.hour,
        reminderMinute: _reminderAllDay ? null : _reminderTime.minute,
        subscriptionEndDate: _subscriptionDurationMonths != null 
            ? DateTime(
                _selectedBillingDate.year,
                _selectedBillingDate.month + _subscriptionDurationMonths!,
                _selectedBillingDate.day,
              )
            : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
        calendarEventId: widget.subscription?.calendarEventId,
        calendarId: widget.subscription?.calendarId,
        lastPaymentDate: widget.subscription?.lastPaymentDate,
        status: widget.subscription?.status ?? SubscriptionStatus.active,
      );

      print('✅ [SAVE] Objeto Subscription creado exitosamente');
      print('🔵 [SAVE] ID: ${subscription.id}');
      print('🔵 [SAVE] Status: ${subscription.status}');
      print('🔵 [SAVE] End Date: ${subscription.subscriptionEndDate}');

      // Guardar suscripción
      print('🔵 [SAVE] Guardando en base de datos...');
      if (widget.subscription == null) {
        print('🔵 [SAVE] Modo: CREAR nueva suscripción');
        await ref.read(subscriptionsProvider.notifier).addSubscription(subscription);
        print('✅ [SAVE] Suscripción CREADA en DB');
      } else {
        print('🔵 [SAVE] Modo: ACTUALIZAR suscripción existente');
        await ref.read(subscriptionsProvider.notifier).updateSubscription(subscription);
        print('✅ [SAVE] Suscripción ACTUALIZADA en DB');
      }

      // Crear/actualizar recordatorio en calendario
      print('🔵 [SAVE] Procesando recordatorio de calendario...');
      String? calendarMessage;
      if (_reminderEnabled) {
        print('🔵 [SAVE] Recordatorio HABILITADO, creando en calendario...');
        final calendarService = CalendarService();
        final hasPermissions = await calendarService.hasPermissions();
        print('🔵 [SAVE] Permisos de calendario: $hasPermissions');
        
        if (hasPermissions || await calendarService.requestPermissions()) {
          print('🔵 [SAVE] Permisos OK, obteniendo calendario predeterminado...');
          final calendarId = await calendarService.getDefaultCalendarId();
          print('🔵 [SAVE] Calendar ID: $calendarId');
          
          if (calendarId != null) {
            print('🔵 [SAVE] Calendario encontrado: $calendarId');
            // Si existe un evento anterior, eliminarlo
            if (subscription.calendarEventId != null && subscription.calendarId != null) {
              print('🔵 [SAVE] Eliminando evento anterior: ${subscription.calendarEventId}');
              await calendarService.deleteReminder(
                subscription.calendarEventId!,
                calendarId: subscription.calendarId,
              );
              print('✅ [SAVE] Evento anterior eliminado');
            }
            
            // Crear nuevo recordatorio
            print('🔵 [SAVE] Creando nuevo recordatorio en calendario...');
            final eventId = await calendarService.createReminder(
              subscription,
              calendarId: calendarId,
            );
            print('🔵 [SAVE] Event ID retornado: $eventId');
            
            if (eventId != null) {
              print('✅ [SAVE] Recordatorio creado exitosamente: $eventId');
              // Actualizar la suscripción con los IDs del calendario
              subscription.calendarEventId = eventId;
              subscription.calendarId = calendarId;
              print('🔵 [SAVE] Actualizando suscripción con IDs de calendario...');
              await ref.read(subscriptionsProvider.notifier).updateSubscription(subscription);
              print('✅ [SAVE] Suscripción actualizada con calendar IDs');
              
              final nextDate = subscription.getNextBillingDate();
              final reminderDate = nextDate.subtract(Duration(days: subscription.reminderDaysBefore));
              calendarMessage = '✅ Recordatorio creado para el ${reminderDate.day}/${reminderDate.month}/${reminderDate.year}';
            } else {
              print('❌ [SAVE] No se pudo crear el recordatorio');
              calendarMessage = '⚠️ No se pudo crear el recordatorio en el calendario';
            }
          } else {
            print('❌ [SAVE] No se encontró calendario disponible');
            calendarMessage = '⚠️ No se encontró un calendario disponible';
          }
        } else {
          print('❌ [SAVE] Permisos de calendario denegados');
          calendarMessage = '⚠️ Se requieren permisos de calendario';
        }
      } else {
        print('🔵 [SAVE] Recordatorio DESHABILITADO, omitiendo calendario');
        // Si se deshabilitó el recordatorio y existe uno, eliminarlo
        if (subscription.calendarEventId != null && subscription.calendarId != null) {
          print('🔵 [SAVE] Eliminando recordatorio deshabilitado...');
          final calendarService = CalendarService();
          await calendarService.deleteReminder(
            subscription.calendarEventId!,
            calendarId: subscription.calendarId,
          );
          subscription.calendarEventId = null;
          subscription.calendarId = null;
          await ref.read(subscriptionsProvider.notifier).updateSubscription(subscription);
          print('✅ [SAVE] Recordatorio eliminado');
        }
      }

      print('✅ [SAVE] Proceso completado exitosamente');

      if (mounted) {
        print('🔵 [SAVE] Navegando de vuelta...');
        Navigator.pop(context);
        
        // Construir mensaje con información del calendario
        String message = widget.subscription == null
            ? 'Suscripción agregada'
            : 'Suscripción actualizada';
        
        if (calendarMessage != null) {
          message += '\n$calendarMessage';
        }
        
        print('🔵 [SAVE] Mostrando SnackBar: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 4),
            backgroundColor: calendarMessage?.contains('⚠️') == true 
                ? Colors.orange 
                : Colors.green,
          ),
        );
        print('✅ [SAVE] Todo completado!');
      }
    } catch (e, stackTrace) {
      print('❌❌❌ [SAVE] ERROR CRÍTICO: $e');
      print('❌ [SAVE] Stack trace: $stackTrace');
      
      if (mounted) {
        print('🔵 [SAVE] Mostrando SnackBar de error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la suscripción: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
