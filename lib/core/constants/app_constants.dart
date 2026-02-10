class FrequencyOptions {
  static const daily = 'daily';
  static const weekly = 'weekly';
  static const biweekly = 'biweekly';
  static const custom = 'custom';

  static const labels = {
    daily: 'Daily',
    weekly: 'Weekly',
    biweekly: 'Bi-Weekly',
    custom: 'Custom',
  };

  static List<String> get values => labels.keys.toList();
}
