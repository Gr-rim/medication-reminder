import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_reminder/features/medication/models/medication.dart';
import 'package:medication_reminder/features/medication/repositories/med_repository.dart';
import 'package:medication_reminder/core/constants/app_constants.dart';

class AddMedScreen extends ConsumerStatefulWidget {
  const AddMedScreen({super.key});

  @override
  ConsumerState<AddMedScreen> createState() => _AddMedScreenState();
}

class _AddMedScreenState extends ConsumerState<AddMedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController(); // ✅ Critical!
  final List<TimeOfDay> _selectedTimes = [TimeOfDay(hour: 8, minute: 0)];
  String _selectedFrequency = FrequencyOptions.daily;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  // Convert TimeOfDay to 12-hour string for display
  String _formatTime12(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🔹 Medicine Name (REQUIRED — was missing!)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Dosage
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., "1 tablet")',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Frequency
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

              // 🔹 Dose Times
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

              // 🔹 Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final id = DateTime.now().millisecondsSinceEpoch
                              .toString();
                          final times24 = _selectedTimes
                              .map(
                                (t) =>
                                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                              )
                              .toList();

                          final med = Medication(
                            id: id,
                            name: _nameController.text.trim(),
                            dosage: _dosageController.text.trim(),
                            times: times24,
                            frequency: _selectedFrequency,
                          );

                          await MedRepository().addMed(med);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Medication saved!'),
                              ),
                            );
                          }
                          context.go('/');
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
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
