String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String formatDateLong(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  const weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  final weekday = weekdays[(d.weekday + 6) % 7];
  final month = months[d.month - 1];
  return '$weekday, $month ${d.day}, ${d.year}';
}

String formatAmount(double value) {
  final sign = value < 0 ? '-' : '';
  final abs = value.abs();
  return '$sign\$${abs.toStringAsFixed(2)}';
}

