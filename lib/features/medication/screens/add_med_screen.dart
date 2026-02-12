// lib/features/medication/screens/add_med_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:medication_reminder/features/medication/models/medication.dart';
import 'package:medication_reminder/features/medication/repositories/med_repository.dart';
import 'package:medication_reminder/core/constants/app_constants.dart';
import 'package:medication_reminder/services/notification_service.dart';

class AddMedScreen extends StatefulWidget {
  final Medication? medication; // null = add mode, non-null = edit mode

  const AddMedScreen({super.key, this.medication});

  @override
  State<AddMedScreen> createState() => _AddMedScreenState();
}

class _AddMedScreenState extends State<AddMedScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final List<TimeOfDay> _selectedTimes;
  late String _selectedFrequency;

  bool get isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final med = widget.medication!;
      _nameController = TextEditingController(text: med.name);
      _dosageController = TextEditingController(text: med.dosage);
      _selectedFrequency = med.frequency;
      _selectedTimes = med.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    } else {
      _nameController = TextEditingController();
      _dosageController = TextEditingController();
      _selectedTimes = [TimeOfDay(hour: 8, minute: 0)];
      _selectedFrequency = FrequencyOptions.daily;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  String _formatTime12(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    final times24 = _selectedTimes
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .toList();

    Medication med;
    if (isEditing) {
      // Update existing
      med = Medication(
        id: widget.medication!.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        times: times24,
        frequency: _selectedFrequency,
      );
    } else {
      // Create new
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      med = Medication(
        id: id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        times: times24,
        frequency: _selectedFrequency,
      );
    }

    await MedRepository().addMed(med);

    // Reschedule notifications
    if (!kIsWeb) {
      // Cancel old notifications if editing
      if (isEditing) {
        // Optional: cancel old notifications (advanced)
        // For MVP, just re-schedule — OS handles duplicates
      }

      for (int i = 0; i < times24.length; i++) {
        final timeStr = times24[i];
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final notificationId = (med.id.hashCode.abs() + i) % 2100000000;

        await NotificationService.scheduleDailyReminder(
          id: notificationId,
          title: 'Time to take ${med.name}',
          body: med.dosage,
          hour: hour,
          minute: minute,
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Medication updated!' : 'Medication saved!',
          ),
        ),
      );
    }
    context.go('/');
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., "1 tablet")',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency *',
                  border: OutlineInputBorder(),
                ),
                items: FrequencyOptions.values.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(FrequencyOptions.labels[freq]!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedFrequency = value);
                },
                validator: (v) => v == null ? 'Select frequency' : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Dose Times (12-hour format)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTimes.map((time) {
                  return Chip(
                    label: Text(_formatTime12(time)),
                    onDeleted: () {
                      if (_selectedTimes.length > 1) {
                        setState(() => _selectedTimes.remove(time));
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(alwaysUse24HourFormat: false),
                        child: child!,
                      );
                    },
                  );
                  if (time != null && !_selectedTimes.contains(time)) {
                    setState(() => _selectedTimes.add(time));
                  }
                },
                icon: const Icon(Icons.alarm),
                label: const Text('Add Dose Time'),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveMedication,
                      icon: const Icon(Icons.check),
                      label: Text(isEditing ? 'Update' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
