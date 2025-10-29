String currency(double value) {
  final isNegative = value < 0;
  final absolute = value.abs();
  final parts = absolute.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decimalPart = parts[1];

  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    final positionFromEnd = intPart.length - i;
    buffer.write(intPart[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }

  var formatted = buffer.toString();
  if (decimalPart != '00') {
    formatted = '$formatted.$decimalPart';
  }

  if (isNegative) {
    return '-₫$formatted';
  }
  return '₫$formatted';
}

String dateShort(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String dateLong(DateTime date) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final month = monthNames[date.month - 1];
  final year = date.year;
  return '$day $month $year';
}
