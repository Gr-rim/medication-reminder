import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medication_reminder/features/medication/models/dose_log.dart';
import 'package:medication_reminder/features/medication/models/medication.dart';
import 'package:medication_reminder/features/medication/repositories/dose_log_repository.dart';
import 'package:medication_reminder/features/medication/repositories/med_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medication> meds = [];
  List<DoseLog> todayDoses = [];
  double weeklyAdherence = 100.0; // ✅ Added missing state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  double _calculateWeeklyAdherence(List<DoseLog> logs) {
    if (logs.isEmpty) return 100.0;
    final taken = logs.where((log) => log.takenAt != null).length;
    return (taken / logs.length) * 100;
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    meds = await MedRepository().getAllMeds();

    final logRepo = DoseLogRepository();
    final existingLogsToday = await logRepo.getLogsForToday();
    final logMapToday = {
      for (var log in existingLogsToday)
        log.scheduledTime.millisecondsSinceEpoch: log,
    };

    final newDoses = <DoseLog>[];
    for (final med in meds) {
      for (final timeStr in med.times) {
        final parts = timeStr.split(':');
        if (parts.length != 2) continue;
        final hour = int.tryParse(parts[0]) ?? 8;
        final minute = int.tryParse(parts[1]) ?? 0;
        final scheduled = DateTime(
          today.year,
          today.month,
          today.day,
          hour,
          minute,
        );

        if (logMapToday.containsKey(scheduled.millisecondsSinceEpoch)) {
          newDoses.add(logMapToday[scheduled.millisecondsSinceEpoch]!);
        } else {
          newDoses.add(
            DoseLog(
              medId: med.id,
              scheduledTime: scheduled,
              takenAt: null,
              isMissed: false,
            ),
          );
        }
      }
    }
    newDoses.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    // Load last 7 days of logs
    final allLogs = await logRepo.getAllLogs(); // ✅ Use public method
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final weeklyLogs = allLogs
        .where((log) => log.scheduledTime.isAfter(sevenDaysAgo))
        .toList();

    if (mounted) {
      setState(() {
        todayDoses = newDoses;
        weeklyAdherence = _calculateWeeklyAdherence(weeklyLogs);
      });
    }
  }

  bool _isToday(DateTime? dt) {
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  void _deleteMedication(Medication med) async {
    final cachedMed = Medication(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      times: List<String>.from(med.times),
      frequency: med.frequency,
    );

    await med.delete();
    _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cachedMed.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await MedRepository().addMed(cachedMed);
            _loadData();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _editMedication(Medication med) {
    context.go('/add-med', extra: med);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No doses scheduled for today',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a medication to get started',
            style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedAdhere'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ✅ Adherence Banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Your adherence this week: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: '${weeklyAdherence.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Dose list or empty
          Expanded(
            child: todayDoses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: todayDoses.length,
                    itemBuilder: (context, index) {
                      final log = todayDoses[index];
                      final med = meds.firstWhere(
                        (m) => m.id == log.medId,
                        orElse: () => throw Exception('Med not found'),
                      );
                      final now = DateTime.now();
                      final isPast = log.scheduledTime.isBefore(now);
                      final isTakenToday =
                          log.takenAt != null && _isToday(log.takenAt);
                      final isMissed = !isTakenToday && isPast;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isTakenToday
                                    ? Colors.green
                                    : isMissed
                                    ? Colors.red
                                    : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${med.dosage} • ${_formatTime12DateTime(log.scheduledTime)}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isTakenToday
                                        ? '✅ Taken'
                                        : isMissed
                                        ? '❌ Missed'
                                        : '⏳ Pending',
                                    style: TextStyle(
                                      color: isTakenToday
                                          ? Colors.green
                                          : isMissed
                                          ? Colors.red
                                          : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isTakenToday && !isMissed)
                              ElevatedButton(
                                onPressed: () async {
                                  final updatedLog = DoseLog(
                                    medId: log.medId,
                                    scheduledTime: log.scheduledTime,
                                    takenAt: DateTime.now(),
                                    isMissed: false,
                                  );
                                  await DoseLogRepository().saveLog(updatedLog);
                                  _loadData();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade100,
                                  foregroundColor: Colors.green.shade800,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Take Now',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            if (isTakenToday || isMissed)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () => _editMedication(med),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18),
                                    onPressed: () => _deleteMedication(med),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-med'),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatTime12DateTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
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
