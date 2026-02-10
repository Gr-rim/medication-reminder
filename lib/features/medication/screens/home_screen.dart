import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medication_reminder/features/medication/models/medication.dart';
import 'package:medication_reminder/features/medication/repositories/med_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medication> meds = [];

  @override
  void initState() {
    super.initState();
    _loadMeds();
  }

  Future<void> _loadMeds() async {
    final repo = MedRepository();
    final loaded = await repo.getAllMeds();
    if (mounted) {
      setState(() => meds = loaded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedAdhere'),
        backgroundColor: Colors.green,
      ),
      body: meds.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.poll, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No medications yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meds.length,
              itemBuilder: (context, index) {
                final med = meds[index];
                final formattedTimes = med.times.map(_formatTime12).join(', ');
                return Dismissible(
                  key: Key(med.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await med.delete();
                    setState(() {
                      meds.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${med.name} removed')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(med.name),
                      subtitle: Text(
                        '${med.dosage} • $formattedTimes • ${_formatFrequency(med.frequency)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add-med');
          // Optional: refresh after returning
          // We'll handle it via manual reload for MVP
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatTime12(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  String _formatFrequency(String freq) {
    switch (freq) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'biweekly':
        return 'Bi-Weekly';
      case 'custom':
        return 'Custom';
      default:
        return freq;
    }
  }
}
