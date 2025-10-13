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
    } else {
      // Modo creación
      _selectedCategory = AppConstants.categories.first;
      _selectedBillingCycle = BillingCycle.monthly;
      _selectedBillingDate = DateTime.now();
      _selectedColor = Colors.blue;
      _reminderEnabled = true;
      _reminderDaysBefore = AppConstants.reminderDaysBefore;
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
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _reminderDaysBefore,
                        decoration: const InputDecoration(
                          labelText: 'Recordar con anticipación',
                          isDense: true,
                        ),
                        items: [1, 2, 3, 5, 7].map((days) {
                          return DropdownMenuItem(
                            value: days,
                            child: Text('$days ${days == 1 ? 'día' : 'días'} antes'),
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

    setState(() {
      _isLoading = true;
    });

    try {
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
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
      );

      // Guardar suscripción
      if (widget.subscription == null) {
        await ref.read(subscriptionsProvider.notifier).addSubscription(subscription);
      } else {
        await ref.read(subscriptionsProvider.notifier).updateSubscription(subscription);
      }

      // Crear/actualizar recordatorio en calendario
      if (_reminderEnabled) {
        final calendarService = CalendarService();
        final hasPermissions = await calendarService.hasPermissions();
        
        if (hasPermissions || await calendarService.requestPermissions()) {
          await calendarService.createReminder(subscription);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.subscription == null
                  ? 'Suscripción agregada'
                  : 'Suscripción actualizada',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la suscripción'),
            backgroundColor: Colors.red,
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
