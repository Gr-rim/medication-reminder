import 'package:hive_flutter/hive_flutter.dart';

part 'medication.g.dart';

@HiveType(typeId: 0)
class Medication extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage; // ✅ Added

  @HiveField(3)
  final List<String> times;

  @HiveField(4)
  final String frequency;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.frequency,
  });
}
